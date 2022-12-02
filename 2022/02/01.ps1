$input = Get-Content $PSScriptRoot\input.txt

$scores = @{
    "A X" = 4
    "B X" = 1
    "C X" = 7
    "A Y" = 8
    "B Y" = 5
    "C Y" = 2
    "A Z" = 3
    "B Z" = 9
    "C Z" = 6
}
$totalScore = 0
foreach($i in $input)
{
    $totalScore += $scores[$i]
}
$totalScore