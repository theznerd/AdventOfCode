#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

$raceTimes = ([regex]'\d+').Matches($puzzleInput[0]).Value
$winningDistances = ([regex]'\d+').Matches($puzzleInput[1]).Value

$product = 1
for($i = 0; $i -lt [int]$raceTimes.Count; $i++)
{
    $winningCount = 0
    for($n = 1; $n -lt [int]$raceTimes[$i]; $n++)
    {
        if($n*([int]$raceTimes[$i] - $n) -gt [int]$winningDistances[$i]){$winningCount++}
    }
    $product *= $winningCount
}
$product