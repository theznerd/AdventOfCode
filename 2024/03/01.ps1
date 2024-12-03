#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

$mulInstructions = ([Regex]::Matches($puzzleInput,"mul\((\d{1,3},\d{1,3})\)")).Groups.Where({$_.Name -eq 1}).Value

$sum = 0
foreach($mul in $mulInstructions){
    [int]$a, [int]$b = $mul.Split(",")
    $sum += $a*$b
}
$sum