#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

$mask = @{
    "N" = @("0","-1")
    "NE" = @("1","-1")
    "E" = @("1","0")
    "SE" = @("1","1")
    "S" = @("0","1")
    "SW" = @("-1","1")
    "W" = @("-1","0")
    "NW" = @("-1","-1")
}

$rollMap = @{}
for($y = 0; $y -lt $puzzleInput.Count; $y++)
{
    for($x = 0; $x -lt $puzzleInput[$y].Length; $x++)
    {
        $rollMap["$x,$y"] = $puzzleInput[$y][$x]
    }
}

$accessibleRolls = 0
foreach($roll in $rollMap.GetEnumerator().Where({$_.Value -eq "@"}))
{
    $x,$y = $roll.Key -split ","
    $countRolls = 0
    foreach($direction in $mask.Keys)
    {
        $dx, $dy = $mask[$direction]
        $nx = [int]$x + [int]$dx
        $ny = [int]$y + [int]$dy
        if($rollMap["$nx,$ny"] -eq "@")
        {
            $countRolls++
        }
    }
    if($countRolls -lt 4){$accessibleRolls++}
}
$accessibleRolls