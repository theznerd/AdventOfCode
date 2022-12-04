$input = Get-Content $PSScriptRoot\input.txt

$overlaps = 0
foreach($pair in $input)
{
    $elfoneLow, $elfoneHigh, $elftwoLow, $elftwoHigh = $pair.Split(',').Split('-')
    [int[]]$elfone = $elfoneLow..$elfoneHigh
    [int[]]$elftwo = $elftwoLow..$elftwoHigh
    ## this ends up being slower than it needs to be
    ## because it's accounting for situations where
    ## an elf could be assigned 1,2,5 rather than a
    ## range (1,2,3,4,5)
    if(([System.Linq.Enumerable]::Intersect($elfone,$elftwo)).Count -gt 0){$overlaps++}
}
$overlaps