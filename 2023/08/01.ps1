#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

$instructions, $null, $map = $puzzleInput -split "\r\n"

enum direction {L;R}
$maps = @{}
foreach($m in $map)
{
    $name, $left, $right = ([regex]'[A-Z]{3}').Matches($m).Value
    $maps.Add($name, @($left,$right))
}

$step = 0
$cLoc = "AAA"
do{
    $cLoc = $maps[$cLoc][[int]([direction]::($instructions[($step % $instructions.Length)]))]
    $step++
}until($cLoc -eq "ZZZ")
$step