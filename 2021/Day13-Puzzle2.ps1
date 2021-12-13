$puzzleInput = Get-Content 'C:\Users\Nathan Ziehnert\OneDrive - Z-Nerd\Documents\AOC\2021\13\input.txt'

$foldInstructions = $puzzleInput.Where({$_.StartsWith("fold along ")}).Replace("fold along ","")
$dotLocations = $puzzleInput.Where({!$_.StartsWith("fold along ")})
$dotLocations = $dotLocations[0..($dotLocations.Count-2)]

$maxX = 0
$maxY = 0
foreach($coordinate in $dotLocations)
{
    if([int]($coordinate.Split(",")[0]) -gt $maxX)
    {
        $maxX = [int]($coordinate.Split(",")[0])
    }
    if([int]($coordinate.Split(",")[1]) -gt $maxY)
    {
        $maxY = [int]($coordinate.Split(",")[1])
    }
}
$maxX++
$maxY++

$initialTransparentPaper = New-Object 'int[,]' $maxX,$maxY
foreach($coordinate in $dotLocations)
{
    $coordinates = [int[]]($coordinate.Split(","))
    $initialTransparentPaper[$coordinates[0],$coordinates[1]] = 1
}

foreach($foldInstruction in $foldInstructions)
{
    $widthOfPaper = $initialTransparentPaper.GetLength(0)
    $heightOfPaper = $initialTransparentPaper.GetLength(1)
    $instructionSet = $foldInstruction.Split("=")
    if($instructionSet[0] -eq "y")
    {
        #fold vertical
        $newTransparentPaper = New-Object 'int[,]' $widthOfPaper, $([Math]::Max([int]($instructionSet[1]), $heightOfPaper - [int]($instructionSet[1])-1))

        # add the dots
        $heightDifferential = ([int]($instructionSet[1])) - ($heightOfPaper-1 - [int]($instructionSet[1]))
        for($y = 0; $y -lt $newTransparentPaper.GetLength(1); $y++)
        {
            for($x = 0; $x -lt $newTransparentPaper.GetLength(0); $x++)
            {
                if($heightDifferential -lt 0)
                {
                    $newTransparentPaper[$x,($y+[Math]::Abs($heightDifferential))] = $initialTransparentPaper[$x,$y] -bor $newTransparentPaper[$x,($y+[Math]::Abs($heightDifferential))]
                    $newTransparentPaper[$x,$y] = $initialTransparentPaper[$x,(-$y-1)] -bor $newTransparentPaper[$x,$y]
                }
                else
                {
                    $newTransparentPaper[$x,$y] = $initialTransparentPaper[$x,$y] -bor $newTransparentPaper[$x,$y]
                    if(($y+[Math]::Abs($heightDifferential)) -lt $newTransparentPaper.GetLength(1)-1)
                    {
                        $newTransparentPaper[$x,($y+[Math]::Abs($heightDifferential))] = $initialTransparentPaper[$x,(-$y-1)] -bor $newTransparentPaper[$x,($y+[Math]::Abs($heightDifferential))]
                    }
                }
            }
        }
        $initialTransparentPaper = $newTransparentPaper
    }
    else
    {
        #fold horizontal
        $newTransparentPaper = New-Object 'int[,]' $([Math]::Max([int]($instructionSet[1]), $widthOfPaper - [int]($instructionSet[1])-1)), $heightOfPaper

        # add the dots
        $widthDifferential = ([int]($instructionSet[1])) - ($widthOfPaper-1 - [int]($instructionSet[1]))
        for($y = 0; $y -lt $newTransparentPaper.GetLength(1); $y++)
        {
            for($x = 0; $x -lt $newTransparentPaper.GetLength(0); $x++)
            {
                if($widthDifferential -lt 0)
                {
                    $newTransparentPaper[($x+[Math]::Abs($widthDifferential)),$y] = $initialTransparentPaper[$x,$y] -bor $newTransparentPaper[($x+[Math]::Abs($widthDifferential)),$y]
                    $newTransparentPaper[$x,$y] = $initialTransparentPaper[(-$x-1),$y] -bor $newTransparentPaper[$x,$y]
                }
                else
                {
                    $newTransparentPaper[$x,$y] = $initialTransparentPaper[$x,$y] -bor $newTransparentPaper[$x,$y]
                    if(($x+[Math]::Abs($widthDifferential)) -lt $newTransparentPaper.GetLength(0)-1)
                    {
                        $newTransparentPaper[($x+[Math]::Abs($widthDifferential)),$y] = $initialTransparentPaper[(-$x-1),$y] -bor $newTransparentPaper[($x+[Math]::Abs($widthDifferential)),$y]
                    }
                }
                
            }
        }
        $initialTransparentPaper = $newTransparentPaper
    }
}

function DrawPaper($paper)
{
    $widthOfPaper = $paper.GetLength(0)
    $heightOfPaper = $paper.GetLength(1)
    for($y = 0; $y -lt $heightOfPaper; $y++)
    {
        $string = ""
        for($x = 0; $x -lt $widthOfPaper; $x++)
        {
            if($paper[$x,$y] -eq 1)
            {
                $string += "#"
            }
            else
            {
                $string += "."
            }
        }
        Write-Output $string
    }
}
DrawPaper $initialTransparentPaper
