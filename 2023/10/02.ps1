#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

## time to "cheat"
Add-Type -AssemblyName PresentationCore ## lots of drawing items in here
Add-Type -AssemblyName WindowsBase

class ElfPipe {
    [int[]]$entry1
    [int[]]$exit1
    [int[]]$entry2
    [int[]]$exit2
    ElfPipe($en1, $ex1, $en2, $ex2)
    {
        $this.entry1 = $en1
        $this.entry2 = $en2
        $this.exit1 = $ex1
        $this.exit2 = $ex2
    }
    [int[]]GetExit ($cx, $cy, $px, $py)
    {
        if($px -eq ($cx+$this.entry1[0]) -and $py -eq ($cy+$this.entry1[1]))
        {
            return @(($cX+$this.exit1[0]),($cY+$this.exit1[1]))
        }
        elseif($px -eq ($cx+$this.entry2[0]) -and $py -eq ($cy+$this.entry2[1]))
        {
            return @(($cX+$this.exit2[0]),($cY+$this.exit2[1]))
        }
        else {
            return -1
        }
    }
}

$connections = @{}
$connections.Add("|", [ElfPipe]::new(@(0,-1),@(0,1),@(0,1),@(0,-1))) # N to S, S to N
$connections.Add("-", [ElfPipe]::new(@(-1,0),@(1,0),@(1,0),@(-1,0))) # E to W, W to E
$connections.Add("L", [ElfPipe]::new(@(0,-1),@(1,0),@(1,0),@(0,-1))) # N to E, E to N
$connections.Add("J", [ElfPipe]::new(@(-1,0),@(0,-1),@(0,-1),@(-1,0))) # W to N, N to W
$connections.Add("7", [ElfPipe]::new(@(-1,0),@(0,1),@(0,1),@(-1,0))) # W to S, S to W
$connections.Add("F", [ElfPipe]::new(@(0,1),@(1,0),@(1,0),@(0,1))) # S to E, E to S

$dx = @(-1, 0, 1, 0)
$dy = @( 0, 1, 0, -1) 

$map = New-Object 'char[,]' $puzzleInput[0].ToCharArray().Count, $puzzleInput.Count
$possibleNests = @{}
$sX = 0
$sY = 0
for($y = 0; $y -lt $map.GetLength(1); $y++)
{
    for($x = 0; $x -lt $map.GetLength(0); $x++)
    {
        if($puzzleInput[$y][$x] -eq "S"){$sX = $x; $sY = $y}
        $map[$x,$y] = $puzzleInput[$y][$x]
        $possibleNests.Add("$x,$y", [System.Windows.Point]::new($x, $y))
    }
}

## First locate the next step in whatever direction from the start
[void]$possibleNests.Remove("$sX,$sY")

for($i = 0; $i -lt 4; $i++)
{
    $neighborX = $sX + $dx[$i]
    $neighborY = $sY + $dy[$i]
    if($neighborX -lt 0 -or $neighborY -lt 0){continue}
    $con = $connections["$($map[($neighborX,$neighborY)])"]
    if($con)
    {
        if($con.GetExit($neighborX, $neighborY, $sX, $sY) -ne -1)        
        {
            $nX, $nY = $neighborX, $neighborY
            break
        }    
    }
}

$pipeFigure = [System.Windows.Media.PathFigure]::new()
$pipeFigure.IsClosed = $true
$pipeFigure.IsFilled = $true
$pipeFigure.StartPoint = "$sX,$sY"

$pipeSegmentCollection = [System.Windows.Media.PathSegmentCollection]::new()
$secondPoint = [System.Windows.Media.LineSegment]::new()
$secondPoint.Point = "$nX,$nY"
$pipeSegmentCollection.Add($secondPoint)

$pX = $sX
$pY = $sY
$cX = $nX
$cY = $nY
$steps = 1
do {
    ## $pX, $pY - our previous position
    ## $cX, $cY - our current position
    ## $nX, $nY - our next position
    [void]$possibleNests.Remove("$cX,$cY")
    $con = $connections["$($map[$cx,$cy])"]
    $nX, $nY = $con.GetExit($cx, $cy, $px, $py)

    ## add another pipe segment
    $newSegment = [System.Windows.Media.LineSegment]::new()
    $newSegment.Point = "$nX,$nY"
    $pipeSegmentCollection.Add($newSegment)

    $pX, $pY = $cX, $cY
    $cX, $cY = $nX, $nY
    $steps++
}until($cX -eq $sX -and $cY -eq $sY)
$pipeFigure.Segments = $pipeSegmentCollection

$pipeLoopGeometry = [System.Windows.Media.PathGeometry]::new()
$pipeLoopGeometry.Figures.Add($pipeFigure)
$pipeLoopGeometry.FillRule = [System.Windows.Media.FillRule]::Nonzero

$nests = 0
foreach($p in $possibleNests.GetEnumerator())
{
    if($pipeLoopGeometry.FillContains($p.Value)){$nests++}
}
$nests