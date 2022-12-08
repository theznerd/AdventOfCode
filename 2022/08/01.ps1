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

$visibleTrees = [System.Collections.Generic.List[string]]@()

for($y = 0; $y -le $maxY; $y++)
{
    $maxLeft = -1
    :row for($x = 0; $x -le $maxX; $x++)
    {
        $currentTree = $treeMap["$x,$y"]
        if($currentTree -gt $maxLeft)
        {
            [void]$visibleTrees.Add("$x,$y")
            $maxLeft = $currentTree
            if($maxLeft -eq 9){break :row}
        }
    }

    $maxRight = -1
    :row for($x = $maxX; $x -ge 0; $x--)
    {
        $currentTree = $treeMap["$x,$y"]
        if($currentTree -gt $maxRight)
        {
            [void]$visibleTrees.Add("$x,$y")
            $maxRight = $currentTree
            if($maxRight -eq 9){break :row}
        }
    }
}
for($x = 0; $x -le $maxX; $x++)
{
    $maxTop = -1
    :column for($y = 0; $y -le $maxY; $y++)
    {
        $currentTree = $treeMap["$x,$y"]
        if($currentTree -gt $maxTop)
        {
            [void]$visibleTrees.Add("$x,$y")
            $maxTop = $currentTree
            if($maxTop -eq 9){break :column}
        }
    }

    $maxBottom = -1
    :column for($y = $maxY; $y -ge 0; $y--)
    {
        $currentTree = $treeMap["$x,$y"]
        if($currentTree -gt $maxBottom)
        {
            [void]$visibleTrees.Add("$x,$y")
            $maxBottom = $currentTree
            if($maxBottom -eq 9){break :column}
        }
    }
}
($visibleTrees | select -unique).Count