#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

$calibrationValue = 0
foreach($line in $puzzleInput){
    $regx = [regex]'\d'
    $numbers = $regx.Matches($line)
    $calibrationValue += [int]"$($numbers[0].Value)$($numbers[-1].Value)"
}
$calibrationValue