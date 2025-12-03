#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

$outputJoltage = 0
foreach($bank in $puzzleInput)
{
    $maxValues = @{}
    $lastMaxIndex = -1 # make sure that we search all the way to the beginning on the first pass
    
    # $i batteries to find, so this forces us to have at least $i batteries by the end 
    # (if the largest number 9 was at the end of the bank, we couldn't make a bank of $i batteries assuming $i > 1)
    for($i = 12; $i -gt 0; $i--) 
    {
        $maxValue = 0

        # search from the end minus $i, but stop before the last value found...
        # basically we want to search between the latest possible battery and
        # the last battery we found in the previous iteration
        for($j = $bank.Length - $i; $j -gt $lastMaxIndex; $j--)
        {
            # we want the largest number searching right to left, but 
            # we want the first occurrence of it from left to right (hence the -ge)
            if([Int]::Parse($bank[$j]) -ge $maxValue)
            {
                $maxValue = [Int]::Parse($bank[$j])
                $currentMaxIndex = $j
            }
        }
        $lastMaxIndex = $currentMaxIndex # this is the end (or beginning depending on how you look at it) of our next search
        $maxValues[$i] = $maxValue # store the max value found for this position
    }
    $outputJoltage += [BigInt]::Parse($maxValues.Values -join '')
}
$outputJoltage