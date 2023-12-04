#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

$parts = @{} # x,y: id - starting position
$symbols = @{} # x,y: symbol

for($y = 0; $y -lt $puzzleInput.Count; $y++){
    $symbolSearcher = ([regex]'[^\.\d\n]').Matches($puzzleInput[$y])
    foreach($symbol in $symbolSearcher){
        $symbols.Add("$($symbol.Index),$y", $symbol.Value)
    }
    $partSearcher = ([regex]'\d+').Matches($puzzleInput[$y])
    foreach($part in $partSearcher){
        $parts.Add("$($part.Index),$y", $part.Value)
    }
}

$sum = 0
:outer foreach($part in $parts.GetEnumerator())
{
    [int]$x, [int]$y = $part.Name.Split(",")
    $len = $part.Value.Length
    for($yt = ($y-1); $yt -le ($y+1); $yt++)
    {
        for($xt = ($x-1); $xt -le ($x+$len); $xt++)
        {
            if($null -ne $symbols["$xt,$yt"]){$sum += $part.Value; continue outer}
        }
    }
}
$sum