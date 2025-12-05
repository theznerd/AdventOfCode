#$puzzleInput = Get-Content $PSScriptRoot\example.txt -Raw
$puzzleInput = Get-Content $PSScriptRoot\input.txt -Raw

$freshIDs, $availableIngredients = $puzzleInput -split "`r`n`r`n"
$freshIDRanges = @()
foreach($freshID in $freshIDs -split "`r`n")
{
    $rangeStart, $rangeEnd = $freshID -split "-"
    $freshIDRanges += ,@([long]$rangeStart, [long]$rangeEnd)
}

$freshIngredients = 0   
:ingredient foreach($ingredient in $availableIngredients -split "`r`n")
{
    foreach($range in $freshIDRanges)
    {
        if([long]$ingredient -ge $range[0] -and [long]$ingredient -le $range[1])
        {
            $freshIngredients++
            continue ingredient
        }
    }
}
$freshIngredients