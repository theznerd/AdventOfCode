$input = Get-Content $PSScriptRoot\input.txt

$scores = @{
    "A X" = 3
    "B X" = 1
    "C X" = 2
    "A Y" = 4
    "B Y" = 5
    "C Y" = 6
    "A Z" = 8
    "B Z" = 9
    "C Z" = 7
}
$totalScore = 0
foreach($i in $input)
{
    $totalScore += $scores[$i]
}
$totalScore