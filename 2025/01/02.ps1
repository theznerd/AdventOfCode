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
    $counter += [Math]::Floor([Math]::Abs($dialposition) / 100) # count full rotations (above or below zero)
    if($dialposition -lt 0 -and -not $dialStartedAtZero){ $counter++ } # when we cross over to the negative we need to add one as the above floor will not count that
    if($dialposition -eq 0){ $counter++ } # when we land on exactly 0, we need to increment the counter, as the floor will not count that

    # reset dial position within bounds (0-99)
    $dialposition = $dialposition % 100
    if($dialposition -eq 0){ $dialStartedAtZero = $true } else { $dialStartedAtZero = $false } # for the crossover check
    if($dialposition -lt 0){ $dialposition += 100 }
}
$counter