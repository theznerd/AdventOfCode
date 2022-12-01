$puzzleInput = Get-Content $PSScriptRoot\input.txt

$elves = [System.Collections.ArrayList]@()
$totalCalories = 0
foreach($line in $puzzleInput)
{
    if([string]::IsNullOrWhiteSpace($line))
    {
        [void]$elves.Add($totalCalories)
        $totalCalories = 0
    }
    else
    {
        $totalCalories += [int]$line
    }
}
[void]$elves.Add($totalCalories)
($elves | Sort-Object -Descending)[0]