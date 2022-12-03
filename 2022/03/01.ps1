$input = Get-Content $PSScriptRoot\input.txt

$prioritySum = 0
foreach($r in $input)
{
    $compartmentOne = $r.Substring(0,($r.Length/2))
    $compartmentTwo = $r.Substring(($r.Length/2))
    $badItem = [System.Linq.Enumerable]::Intersect($compartmentOne,$compartmentTwo)
    if($badItem -cmatch "[A-Z]"){
        $prioritySum += ([byte][char]"$badItem")-38
    }else{
        $prioritySum += ([byte][char]"$badItem")-96
    }
}
$prioritySum