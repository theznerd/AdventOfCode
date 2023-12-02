#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

$maxValue = @{
    red = 12
    green = 13
    blue = 14
}

$sum = 0
:outer for($i = 1; $i -le $puzzleInput.Count; $i++)
{
    $gameId = $i
    $pulls = ($puzzleInput[($i-1)])[(7 + ([string]$i).Length)..($puzzleInput[($i-1)].Length)] -join '' -split '; '
    foreach($pull in $pulls)
    {
        $colors = $pull -split ", "
        foreach($color in $colors)
        {
            $number, $colorid = $color -split ' '
            if($maxValue[$colorid] -lt [int]$number){continue outer}
        }
    }
    $sum += $gameId
}
$sum