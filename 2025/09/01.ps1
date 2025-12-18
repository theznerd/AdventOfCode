#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

$points = [Collections.Generic.List[object]]::new()
foreach($line in $puzzleInput){
    $x, $y = $line -split ","
    $point = [PSCustomObject]@{
        x = [int]$x
        y = [int]$y
    }
    $points.Add($point)
}
$maxArea = 0

# Calculate area for each pair of points... yuck...
for($i = 0; $i -lt $points.Count - 1; $i++){
    for($j = $i + 1; $j -lt $points.Count; $j++){
        $pointA = $points[$i]
        $pointB = $points[$j]
        $area = ([Math]::Abs($pointA.x - $pointB.x) + 1) * ([Math]::Abs($pointA.y - $pointB.y) + 1)
        if($area -gt $maxArea){
            $maxArea = $area
        }
    }
}
$maxArea