$input = Get-Content $PSScriptRoot\input.txt

$prioritySum = 0
for($r = 0; $r -lt $input.count; $r += 3)
{
    $bagOne = $input[$r]
    $bagTwo = $input[($r+1)]
    $bagThree = $input[($r+2)]

    $firstIntersect = [System.Linq.Enumerable]::Intersect($bagOne,$bagTwo) -join ''
    $priority = [System.Linq.Enumerable]::Intersect($firstIntersect,$bagThree)

    if($priority -cmatch "[A-Z]"){
        $prioritySum += ([byte][char]"$priority")-38
    }else{
        $prioritySum += ([byte][char]"$priority")-96
    }
}
$prioritySum