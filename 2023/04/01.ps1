#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

$points = 0
foreach($card in $puzzleInput)
{
    if($card -match 'Card\s+(\d+):\s+([\d\s]+)\|\s+([\d\s]+)'){
        $cardId, $winningNumbers, $myNumbers = $matches[1..3]
        $winningNumbers = [regex]::Split($winningNumbers, "\s+")
        $myNumbers = [regex]::Split($myNumbers, "\s+")
    }

    $winningCount = [Linq.Enumerable]::Count([Linq.Enumerable]::Intersect($winningNumbers,$myNumbers))
    if($winningCount -gt 0){$points += [Math]::Pow(2,($winningCount - 1))}
}
$points