$puzzleInput = Get-Content 'C:\Users\Nathan Ziehnert\OneDrive - Z-Nerd\Documents\AOC\2021\14\input.txt'
$polymerTemplate = $puzzleInput[0]
$pairInsertionRuleList = $puzzleInput[2..($puzzleInput.Length-1)]

$valueTable = @{}
foreach($pair in $pairInsertionRuleList)
{
    $pairArray = $pair -split(' -> ')
    $countOf = ([regex]::Matches($polymerTemplate, '(?=(\w\w))')).Groups.Where({$_.Value -eq $pairArray[0]}).Count
    $valueTable.Add($pairArray[0], @(@("$(($pairArray[0])[0])$($pairArray[1])","$($pairArray[1])$(($pairArray[0])[1])"),$countOf))
}

$iterations = 40
for($i = 0; $i -lt $iterations; $i++)
{
    $newValueTable = @{}
    foreach($pair in $pairInsertionRuleList)
    {
        $pairArray = $pair -split(' -> ')
        $newValueTable.Add($pairArray[0], @(@("$(($pairArray[0])[0])$($pairArray[1])","$($pairArray[1])$(($pairArray[0])[1])"),0))
    }
    foreach($key in $valueTable.Keys)
    {
        foreach($subValue in ($valueTable[$key])[0])
        {
            ($newValueTable[$subValue])[1] += ($valueTable[$key])[1]
        }
    }
    $valueTable = $newValueTable.Clone()
}

$countValues = @{}
foreach($key in $valueTable.Keys)
{
    if($countValues.Keys -notcontains $key[0])
    {
        $countValues.Add($key[0],($valueTable[$key])[1])
    }
    else
    {
        $countValues[$key[0]] += ($valueTable[$key])[1]
    }
    if($countValues.Keys -notcontains $key[1])
    {
        $countValues.Add($key[1],($valueTable[$key])[1])
    }
    else
    {
        $countValues[$key[1]] += ($valueTable[$key])[1]
    }
}
$newCount = $countValues.Clone()
foreach($key in $countValues.Keys)
{
    $newCount[$key] = [Math]::Ceiling($countValues[$key]/2)
}
($newCount.GetEnumerator() | sort value -Descending | select -First 1).Value - ($newCount.GetEnumerator() | sort value | select -First 1).Value
