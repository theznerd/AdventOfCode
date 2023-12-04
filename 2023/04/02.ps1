#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

$cardCount = @{}
1..($puzzleInput.Count) | ForEach-Object { $cardCount[$_] = 1 }

foreach($card in $puzzleInput)
{
    if($card -match 'Card\s+(\d+):\s+([\d\s]+)\|\s+([\d\s]+)'){
        [int]$cardId, $winningNumbers, $myNumbers = $matches[1..3]
        $winningNumbers = [regex]::Split($winningNumbers, "\s+")
        $myNumbers = [regex]::Split($myNumbers, "\s+")
    }

    $winningCount = [Linq.Enumerable]::Count([Linq.Enumerable]::Intersect($winningNumbers,$myNumbers))
    if($winningCount -gt 0){
        for($n = $cardId + 1; $n -le $cardId + $winningCount; $n++){
            if($cardCount.ContainsKey($n)){$cardCount[$n] += $cardCount[$cardId]}
        }
    }
}
($cardCount.Values | Measure-Object -Sum).Sum