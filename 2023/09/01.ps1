#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

function Get-NextLevel ($history){
    $nextLevel = [System.Collections.Generic.List[int]]::new()
    for($i = 0; $i -lt ($history.Count - 1); $i++)
    {
        $nextLevel.Add(($history[($i+1)] - $history[($i)]))
    }
    return ,$nextLevel
}

function Get-ValueMap ($history, $valueMap = [System.Collections.Generic.List[object]]::new())
{
    $valueMap.Add($history)
    $nextLevel = Get-NextLevel($history)
    if([System.Linq.Enumerable]::Count([System.Linq.Enumerable]::Distinct($nextLevel)) -eq 1 -and $nextLevel[0] -eq 0)
    {
        $valueMap.Add($nextLevel)
        return ,$valueMap
    }
    else {
        return ,(Get-ValueMap $nextLevel $valueMap)
    }
}

function Get-NextValue ($valueMap)
{
    $nextValue = 0
    for($l = ($valueMap.Count - 2); $l -ge 0; $l--)
    {
        $nextValue += $valueMap[$l][-1]
    }
    $nextValue
}

$sum = 0
for($i = 0; $i -lt $puzzleInput.Count; $i++)
{
    $history = [int[]]($puzzleInput[$i] -split " ")
    $vm = Get-ValueMap $history
    $sum += Get-NextValue $vm
}
$sum