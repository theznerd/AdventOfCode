$puzzleInput = Get-Content 'C:\Users\Nathan Ziehnert\OneDrive - Z-Nerd\Documents\AOC\2021\05\Input.txt'
$lines = @()
foreach($input in $puzzleInput)
{
    $split = $input -split ' -> '
    [int]$x1,[int]$y1 = $split[0].Split(',')
    [int]$x2,[int]$y2 = $split[1].Split(',')

    #determine line points
    $dx = $x2 - $x1
    $dy = $y2 - $y1
    $dt = [Math]::Max([Math]::Abs($dx),[Math]::Abs($dy))
    $xSlope = $dx / $dt;
    $ySlope = $dy / $dt;
    
    $linePoints = @()
    $xPointer = $x1
    $yPointer = $y1   
    for($i = 0; $i -le $dt; $i++)
    {
        $linePoints += "$xPointer,$yPointer"
        #$linePoints += [pscustomobject]@{X = $xPointer; Y = $yPointer}
        $xPointer += $xSlope
        $yPointer += $ySlope
    }
    $lines += [pscustomobject]@{X1 = $x1; X2 = $x2; Y1 = $y1; Y2 = $y2; LinePoints = $linePoints}
}

# Puzzle 2
($lines.LinePoints | Group-Object | Where-Object {$_.Count -gt 1}).Count
