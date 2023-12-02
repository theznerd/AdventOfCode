#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

$sum = 0
for($i = 1; $i -le $puzzleInput.Count; $i++)
{
    $pulls = ($puzzleInput[($i-1)])[(7 + ([string]$i).Length)..($puzzleInput[($i-1)].Length)] -join '' -split '; '
    $lowestValue = @{
        red = 1
        green = 1
        blue = 1
    }
    foreach($pull in $pulls)
    {
        $colors = $pull -split ", "
        foreach($color in $colors)
        {
            $number, $colorid = $color -split ' '
            if($lowestValue[$colorid] -lt [int]$number){$lowestValue[$colorid] = [int]$number}
        }
    }
    $gamePower = $lowestValue['red']*$lowestValue['blue']*$lowestValue['green']
    $sum += $gamePower
}
$sum