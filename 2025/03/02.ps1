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

        # search from the right minus $i (leaves enough batteries on the right side to
        # make a bank of $i batteries), but stop before the last value found...
        # basically we want to search between the furthest possible right battery 
        # and the last battery we found in the previous iteration
        for($j = $bank.Length - $i; $j -gt $lastMaxIndex; $j--)
        {
            # we want the largest number searching right to left, but 
            # we want the first occurrence of it from left to right to
            # maximize the remaining batteries for the next searches
            if([Int]::Parse($bank[$j]) -ge $maxValue)
            {
                $maxValue = [Int]::Parse($bank[$j])
                $currentMaxIndex = $j
            }
        }
        $lastMaxIndex = $currentMaxIndex # this is the "leftmost" index for the next search
        $maxValues[$i] = $maxValue # store the max value found for this position
    }
    $outputJoltage += [BigInt]::Parse($maxValues.Values -join '')
}
$outputJoltage