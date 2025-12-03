#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

$outputJoltage = 0
foreach($bank in $puzzleInput)
{
    $maxValues = @{}
    $lastMaxIndex = -1
    for($i = 12; $i -gt 0; $i--)
    {
        $maxValue = 0
        for($j = $bank.Length - $i; $j -gt $lastMaxIndex; $j--)
        {
            if([Int]::Parse($bank[$j]) -ge $maxValue)
            {
                $maxValue = [Int]::Parse($bank[$j])
                $currentMaxIndex = $j
            }
        }
        $lastMaxIndex = $currentMaxIndex
        $maxValues[$i] = $maxValue
    }
    $outputJoltage += [BigInt]::Parse($maxValues.Values -join '')
}
$outputJoltage