#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

$left = [Array]::CreateInstance([int], $puzzleInput.Length)
$right = [Array]::CreateInstance([int], $puzzleInput.Length)
for($i = 0; $i -lt $puzzleInput.Length; $i++){
    $left[$i], $right[$i] = $puzzleInput[$i].split("   ")
}

$similarity = 0
foreach($l in $left){
    $similarity += $l * ($right.Where({$_ -eq $l})).Count
}
$similarity