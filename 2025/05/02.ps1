#$puzzleInput = Get-Content $PSScriptRoot\example.txt -Raw
$puzzleInput = Get-Content $PSScriptRoot\input.txt -Raw

class Range : IComparable {
    [long]$Start
    [long]$End
    Range([long]$start, [long]$end){
        $this.Start = $start
        $this.End = $end
    }

    [int]CompareTo($other) {
        if ($this.Start -lt $other.Start) { return -1 }
        if ($this.Start -gt $other.Start) { return 1 }
        return 0
    }
}

$freshIDs, $null = $puzzleInput -split "`r`n`r`n"
$freshIDRanges = [Collections.Generic.List[Range]]::new()
foreach($freshID in $freshIDs -split "`r`n")
{
    $rangeStart, $rangeEnd = $freshID -split "-"
    $freshIDRanges.Add([Range]::new([long]$rangeStart, [long]$rangeEnd))
}
$freshIDRanges.Sort()

# Merge overlapping ranges
do{
    $changesMade = $false
    for($i = 0; $i -lt $freshIDRanges.Count - 1; $i++) # iterate through all the ranges
    {
        for($j = $i + 1; $j -lt $freshIDRanges.Count; $j++) # check all subsequent ranges (we sorted by start already, so can assume earlier ranges start earlier)
        {
            if($freshIDRanges[$j].Start -le $freshIDRanges[$i].End)
            {
                # Ranges overlap, merge them
                $freshIDRanges[$i].End = [math]::Max($freshIDRanges[$i].End, $freshIDRanges[$j].End)
                $freshIDRanges.RemoveAt($j)
                $changesMade = $true
            }
        }
    }
} while($changesMade -eq $true) # repeat until all the ranges are merged

[long]$totalFreshIDs = 0
foreach($range in $freshIDRanges)
{
    $totalFreshIDs += ($range.End - $range.Start + 1)
}
$totalFreshIDs