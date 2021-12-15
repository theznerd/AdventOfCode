$puzzleInput = Get-Content 'C:\Users\Nathan Ziehnert\OneDrive - Z-Nerd\Documents\AOC\2021\15\input.txt'
$puzzleXMax = $puzzleInput[0].Length
$puzzleYMax = $puzzleInput.Count
$dx = @(-1, 0, 1, 0)
$dy = @( 0, 1, 0, -1) 

function InsideGrid($x, $y)
{
    return (($x -in 0..($puzzleXMax-1)) -and ($y -in 0..($puzzleYMax-1)))
}

#Build map
$coordinates = @{}
for($y = 0; $y -lt $puzzleYMax; $y++)
{
    for($x = 0; $x -lt $puzzleXMax; $x++)
    {
        $coordinates["$x,$y"] = [pscustomobject]@{
            Name = "$x,$y"
            x = $x
            y = $y
            Risk = $([int]::Parse(($puzzleInput[$y].ToCharArray())[$x]))
            Cost = [int]::MaxValue
            Visited = $false
        }
    }
}
$coordinates["0,0"].Risk = 0 #0,0 is never entered in a path that ends at finish
$coordinates["0,0"].Cost = 0 #it costs nothing to start here
#----- Map Built

$priorityQueue = [System.Collections.ArrayList]::new()
[void]$priorityQueue.Add([pscustomobject]@{Coordinate = $coordinates["0,0"]; Priority = 0})

while($priorityQueue.Count -gt 0)
{
    # pop top item from priority queue
    $coordinate, $priorityQueue = $priorityQueue
    $coordinate = $coordinate.Coordinate
    if($null -eq $priorityQueue)
    {$priorityQueue = [System.Collections.ArrayList]::new()}
    else
    {$priorityQueue = [System.Collections.ArrayList]::new(@($priorityQueue))}

    if($coordinate.Visited){continue}
    $coordinate.Visited = $true

    if($coordinate.Name -eq "$($puzzleXMax-1),$($puzzleYMax-1)")
    {
        return $coordinate.Cost
    }

    for($i = 0; $i -lt 4; $i++)
    {
        $neighborX = $coordinate.x + $dx[$i]
        $neighborY = $coordinate.y + $dy[$i]

        if(!(InsideGrid $neighborX $neighborY))
        {
            continue
        }

        $coordCost = $coordinate.Cost + $coordinates["$neighborX,$neighborY"].Risk
        if($coordCost -lt $coordinates["$neighborX,$neighborY"].Cost)
        {
            $coordinates["$neighborX,$neighborY"].Cost = $coordCost
        }

        if($coordinates["$neighborX,$neighborY"].Cost -ne [int]::MaxValue)
        {
            [void]$priorityQueue.Add([pscustomobject]@{Coordinate = $coordinates["$neighborX,$neighborY"]; Priority = $coordinates["$neighborX,$neighborY"].Cost})
        }
    }
    $priorityQueue = [System.Collections.ArrayList]::new(@($priorityQueue | sort Priority))
}
$coordinates["$($puzzleXMax-1),$($puzzleYMax-1)"].Cost
