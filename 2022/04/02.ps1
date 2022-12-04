$input = Get-Content $PSScriptRoot\input.txt

$overlaps = 0
foreach($pair in $input)
{
    $elfoneLow, $elfoneHigh, $elftwoLow, $elftwoHigh = $pair.Split(',').Split('-')
    [int[]]$elfone = $elfoneLow..$elfoneHigh
    [int[]]$elftwo = $elftwoLow..$elftwoHigh
    if(([System.Linq.Enumerable]::Intersect($elfone,$elftwo)).Count -gt 0){$overlaps++}
}
$overlaps