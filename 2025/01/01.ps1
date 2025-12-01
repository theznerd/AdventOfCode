#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

$dialposition = 50
$counter = 0

foreach($instruction in $puzzleInput)
{
    switch($instruction[0]){
        "L" { $dialposition -= $instruction.Substring(1) }
        "R" { $dialposition += $instruction.Substring(1) }
    }
    if($dialposition % 100 -eq 0){$counter++}
}
$counter