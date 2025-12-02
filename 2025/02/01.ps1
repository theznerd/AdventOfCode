#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

$sumOfInvalidIds = 0
foreach($range in $puzzleInput.Split(","))
{
    $rangeStart, $rangeEnd = $range -split "-"

    # We know that matches must be equal in length (e.g. if range start is 6 digits long,
    # then the pattern must be 3+3 matching digits), at least for part 1. The puzzle input
    # seems to indicate there is never a delta in length of more than 1 digit (e.g. 99-100,
    # but not 99-1000).
    $rangeLengthDelta = $rangeEnd.Length - $rangeStart.Length

    # Here we can determine the search space for the candidates.
    if($rangeStart.Length % 2 -eq 0){
        # if the starting range is an even number of digits we start here (with the first half of number)
        $startSearch = $rangeStart.Substring(0,($rangeStart.Length / 2))

        # if the ending range is + 1 digit, we only go up to the max for half the starting range digit length
        if($rangeLengthDelta -eq 1){$endSearch = "9" * ($rangeEnd.Length / 2)}
        else{$endSearch = $rangeEnd.Substring(0,($rangeEnd.Length / 2))}
    }elseif($rangeEnd.Length % 2 -eq 0){
        # if the starting range is an odd number of digits, we start at lowest number for the end range length (e.g. 100 for 3 digit start
        # and then go up to the half-length of the even end range)
        $startSearch = "1" + ("0" * ((($rangeEnd.Length) / 2) - 1))
        $endSearch = $rangeEnd.Substring(0,($rangeEnd.Length / 2))
    }

    # all our possible candidates in part 1 involve a doubly repeated pattern
    $possibleCandidates = for($i = [long]$startSearch; $i -le [long]$endSearch; $i++){"$i$i"}
    foreach($candidate in $possibleCandidates)
    {
        $candidateInt = [long]$candidate
        if($candidateInt -ge [long]$rangeStart -and $candidateInt -le [long]$rangeEnd)
        {
            $sumOfInvalidIds += $candidateInt
        }
    }
}
$sumOfInvalidIds