$input = Get-Content $PSScriptRoot\input.txt

$maxX = $input[0].Length - 1
$maxY = $input.Count - 1

## Build the Tree Map
$treeMap = @{}
$y = 0
foreach($r in $input)
{
    for($x = 0; $x -lt $r.Length; $x++)
    {
        [void]$treeMap.Add("$x,$y","$($r[$x])")
    }
    $y++
}

$maxScenicScore = 0

for($y = 1; $y -lt $maxY; $y++)
{
    for($x = 1; $x -lt $maxX; $x++)
    {
        #look left
        $leftView = 0
        :look for($xPos = $x-1; $xPos -ge 0; $xPos--)
        {   
            $leftView++
            if($treeMap["$xPos,$y"] -ge $treeMap["$x,$y"])
            {
                # max left reached
                break :look
            }
        }
        
        #look right
        $rightView = 0
        :look for($xPos = $x+1; $xPos -le $maxX; $xPos++)
        {   
            $rightVIew++
            if($treeMap["$xPos,$y"] -ge $treeMap["$x,$y"])
            {
                # max right reached
                break :look
            }
        }

        #look up
        $upView = 0
        :look for($yPos = $y-1; $yPos -ge 0; $yPos--)
        {
            $upView++
            if($treeMap["$x,$yPos"] -ge $treeMap["$x,$y"])
            {
                # max up reached
                break :look
            }
        }

        #look down
        $downView = 0
        :look for($yPos = $y+1; $yPos -le $maxY; $yPos++)
        {
            $downView++
            if($treeMap["$x,$yPos"] -ge $treeMap["$x,$y"])
            {
                # max up reached
                break :look
            }
        }

        #multiply
        $scenicScore = $leftView * $rightView * $upView * $downView

        if($scenicScore -gt $maxScenicScore){$maxScenicScore = $scenicScore}
    }
}
$maxScenicScore