#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

$left = [Array]::CreateInstance([int], $puzzleInput.Length)
$right = [Array]::CreateInstance([int], $puzzleInput.Length)

for($i = 0; $i -lt $puzzleInput.Length; $i++){
    $left[$i], $right[$i] = $puzzleInput[$i].split("   ")
}
[Array]::Sort($left)
[Array]::Sort($right)

$tdistance = 0
for($i = 0; $i -lt $puzzleInput.Length; $i++){
    $tdistance += [Math]::Abs(($left[$i] - $right[$i]))
}
$tdistance