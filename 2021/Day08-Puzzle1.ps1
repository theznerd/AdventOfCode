$puzzleInput = Get-Content 'C:\Users\Nathan Ziehnert\OneDrive - Z-Nerd\Documents\AOC\2021\08\input.txt'

$fourDigitSegments = @()
foreach($segment in $puzzleInput)
{
    $split = ($segment -Split ' \| ')
    $segments = $split[1].Split(" ")
    $fourDigitSegments += [pscustomobject]@{
        Notes = $split[0]
        Segment1 = $segments[0]
        Segment2 = $segments[1]
        Segment3 = $segments[2]
        Segment4 = $segments[3]
    }
}

$count1 = ($fourDigitSegments.Segment1 | Where-Object {$_.ToCharArray().Count -in @(2,4,3,7)}).Count
$count2 = ($fourDigitSegments.Segment2 | Where-Object {$_.ToCharArray().Count -in @(2,4,3,7)}).Count
$count3 = ($fourDigitSegments.Segment3 | Where-Object {$_.ToCharArray().Count -in @(2,4,3,7)}).Count
$count4 = ($fourDigitSegments.Segment4 | Where-Object {$_.ToCharArray().Count -in @(2,4,3,7)}).Count
$count1+$count2+$count3+$count4
