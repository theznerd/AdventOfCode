#Slow as molasses
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
$puzzleXMax = $puzzleInput[0].Length * 5 
$puzzleYMax = $puzzleInput.Count * 5
$puzzleMap = New-Object 'object[,]' $puzzleXMax,$puzzleYMax

#fill initial
$coordinates = @{}
for($x = 0; $x -lt $puzzleXMax/5; $x++)
{
    for($y = 0; $y -lt $puzzleYMax/5; $y++)
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

#fill right
for($i = 1; $i -lt 5; $i++)
{
    for($x = 0; $x -lt $puzzleXMax/5; $x++)
    {
        for($y = 0; $y -lt $puzzleYMax/5; $y++)
        {
            $risk = $coordinates["$($x+(($puzzleXMax/5)*$i)-($puzzleXMax/5)),$y"].Risk + 1
            if($risk -eq 10){$risk = 1}
            $coordinates["$($x+(($puzzleXMax/5)*$i)),$y"] = [pscustomobject]@{
                Name = "$($x+(($puzzleXMax/5)*$i)),$y"
                x = $($x+(($puzzleXMax/5)*$i))
                y = $y
                Risk = $risk
                Cost = [int]::MaxValue
                Visited = $false
            }
        }
    }
}

#fill down
for($i = 1; $i -lt 5; $i++)
{
    for($y = 0; $y -lt $puzzleYMax/5; $y++)
    {
        for($x = 0; $x -lt $puzzleXMax; $x++)
        {
            $risk = $coordinates["$x,$($y+(($puzzleYMax/5)*$i)-($puzzleYMax/5))"].Risk + 1
            if($risk -eq 10){$risk = 1}
            $coordinates["$x,$($y+(($puzzleXMax/5)*$i))"] = [pscustomobject]@{
                Name = "$x,$($y+(($puzzleXMax/5)*$i))"
                x = $x
                y = $($y+(($puzzleXMax/5)*$i))
                Risk = $risk
                Cost = [int]::MaxValue
                Visited = $false
            }
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
