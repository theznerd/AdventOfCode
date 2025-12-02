#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

$sumOfInvalidIds = 0
foreach($range in $puzzleInput.Split(","))
{
    $rangeStart, $rangeEnd = $range -split "-"

    # Well wouldn't you know it... now we have to account for all different lengths
    # of patterns... which means our number set now includes odd-length numbers as well.
    # So at this point the delta doesn't really matter, but we need to figure out how to
    # generate all the possible pattern candidates.

    # Theoretically the longest possible matching pattern would be half of the longest
    # number in the range. So we can generate candidates from 1 in length up to that max
    $maxPatternLength = [math]::Floor($rangeEnd.Length / 2) # We take the floor here because 5 would never be a valid pattern length for a 9 digit number
    
    # to make this easier to reason about, let's split the ranges into their two length groups
    $rangesToSearch = @()
    if($rangeStart.Length -eq $rangeEnd.Length)
    {
        $rangesToSearch += ,@($rangeStart, $rangeEnd)
    }else{
        $firstRangeEnd = ("9" * $rangeStart.Length)
        $secondRangeStart = "1" + ("0" * ($rangeEnd.Length - 1))
        $rangesToSearch += ,@($rangeStart, $firstRangeEnd)
        $rangesToSearch += ,@($secondRangeStart, $rangeEnd)
    }

    # now we can iterate over each sub-range
    $possibleCandidates = @()
    foreach($subRange in $rangesToSearch)
    {
        $subRangeStart = $subRange[0]
        $subRangeEnd = $subRange[1]
        for($i = 1; $i -le $maxPatternLength; $i++)
        {
            # now we're iterating over possible pattern lengths
            # what we need to be aware of is the number of times the pattern is repeated
            # for example, in a 10 digit number, a pattern of length 2 would repeat 5 times
            $patternRepeatCount = [math]::Floor($subRangeStart.Length / $i)

            $rangePatternStart = [long]($subRangeStart.Substring(0, $i))
            $rangePatternEnd = [long]($subRangeEnd.Substring(0, $i))

            # only include candidates that are of at least length 2 (1 digit twice), 
            # and that match the length of the sub-range when repeated
            [long[]]$possibleCandidates += for($p = $rangePatternStart; $p -le $rangePatternEnd; $p++){if (("$p" * $patternRepeatCount).Length -eq $subRangeStart.Length -and ("$p" * $patternRepeatCount).Length -gt 1){"$p" * $patternRepeatCount}}
        }
    }
    $possibleCandidates = $possibleCandidates | Select-Object -Unique # deduplicate candidates
    foreach($candidate in $possibleCandidates) # check candidates against the full range
    {
        $candidateInt = [long]$candidate
        if($candidateInt -ge [long]$rangeStart -and $candidateInt -le [long]$rangeEnd)
        {
            $sumOfInvalidIds += $candidateInt
        }
    }
}
$sumOfInvalidIds