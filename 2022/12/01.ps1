$puzzleInput = Get-Content $PSScriptRoot\input.txt

$maxX = $puzzleInput[0].ToCharArray().Count
$maxY = $puzzleInput.Count
$map = New-Object "Node[,]" $maxX,$maxY

class Node {
    [int]$height
    [bool]$visited = $false
    [int]$cost = [int]::MaxValue
    [int]$x
    [int]$y
    Node($h, $x, $y)
    {
        $this.height = $h
        $this.x = $x
        $this.y = $y
    }
}

## fill out our map
for($y = 0; $y -lt $maxY; $y++)
{
    $row = $puzzleInput[$y].ToCharArray()
    for($x = 0; $x -lt $maxX; $x++)
    {
        $height = [int]$row[$x]
        if($height -eq 83)
        {
            ## starting position
            $height = 0
            $startLocation = @($x,$y)
        }
        elseif($height -eq 69)
        {
            ## ending position
            $height = 25
            $endLocation = @($x,$y)
        }
        else{$height -= 97}
        $map[$x,$y] = [Node]::new($height, $x, $y)
    }
}

## Coordinate Fun
$dx = @(0,-1, 0, 1)
$dy = @(1, 0,-1, 0)

## Dijkstra
function Test-InsideGrid($x,$y)
{
    return (($x -ge 0 -and $x -lt $maxX) -and ($y -ge 0 -and $y -lt $maxY))
}

$startNode = $map[$startLocation[0],$startLocation[1]]
$startNode.cost = 0

$priorityQueue = [System.Collections.Generic.PriorityQueue[Node,int]]::new()
[void]$priorityQueue.Enqueue($startNode,0)  ## start at the starting location

while($priorityQueue.Count -gt 0)
{
    $node = $priorityQueue.Dequeue()
    
    if($node.visited){continue}
    $node.visited = $true

    for($i = 0; $i -lt 4; $i++)
    {
        $neighborX = $node.x + $dx[$i]
        $neighborY = $node.y + $dy[$i]

        if(!(Test-InsideGrid $neighborX $neighborY)){continue}

        ## "infinite" cost if the height difference is greater than one
        if((($map[$neighborX,$neighborY].height - $node.height) -gt 1)){
            $cost = [int]::MaxValue
        }else{
            $cost = $node.cost + 1
        }
        
        if($cost -lt $map[$neighborX,$neighborY].Cost)
        {
            $map[$neighborX,$neighborY].Cost = $cost
        }

        if($map[$neighborX,$neighborY].Cost -ne [int]::MaxValue)
        {
            [void]$priorityQueue.Enqueue(($map[$neighborX,$neighborY]), ($map[$neighborX,$neighborY].Cost))
        }
    }
}
$map[$endLocation[0],$endLocation[1]].Cost