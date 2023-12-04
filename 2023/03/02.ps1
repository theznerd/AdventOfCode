#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

$parts = @{} # x,y (start): id
$symbols = @{} # x,y: matches

for($y = 0; $y -lt $puzzleInput.Count; $y++){
    $symbolSearcher = ([regex]'\*').Matches($puzzleInput[$y]) #only match gears
    foreach($symbol in $symbolSearcher){
        $symbols.Add("$($symbol.Index),$y", @())
    }
    $partSearcher = ([regex]'\d+').Matches($puzzleInput[$y])
    foreach($part in $partSearcher){
        $parts.Add("$($part.Index),$y", $part.Value)
    }
}

foreach($part in $parts.GetEnumerator())
{
    $touchingGears = @{}
    [int]$x, [int]$y = $part.Name.Split(",")
    $len = $part.Value.Length
    for($yt = ($y-1); $yt -le ($y+1); $yt++)
    {
        for($xt = ($x-1); $xt -le ($x+$len); $xt++)
        {
            if($null -ne $symbols["$xt,$yt"] -and $null -eq $touchingGears["$xt,$yt"]){$touchingGears.Add("$xt,$yt",1)}
        }
    }
    foreach($g in $touchingGears.GetEnumerator()){
        $symbols["$($g.Name)"] += $part.Value
    }
}

$ratioSum = 0
foreach($gear in $symbols.GetEnumerator() | Where-Object {($_.Value).Count -eq 2})
{
    $ratioSum += [int]($gear.Value)[0]*[int]($gear.Value)[1]
}
$ratioSum