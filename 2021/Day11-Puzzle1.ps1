$puzzleInput = Get-Content 'C:\Users\Nathan Ziehnert\OneDrive - Z-Nerd\Documents\AOC\2021\11\input.txt'
$puzzleX = $puzzleInput[0].ToCharArray().Count
$puzzleY = $puzzleInput.Count
$octopuses = New-Object 'object[,]' $puzzleX,$puzzleY

#Build map
for($y = 0; $y -lt $puzzleY; $y++)
{
    for($x = 0; $x -lt $puzzleX; $x++)
    {
        $octopuses[$x,$y] = @{
            power = $([int]::Parse(($puzzleInput[$y].ToCharArray())[$x]))
            flashed = $false
        }
    }
}

function IncreaseEnergy($octopusArray)
{
    foreach($octopus in $octopusArray)
    {
        $octopus.power++
    }
}

function FlashOctopuses($octopusArray)
{
    for($y = 0; $y -lt $puzzleY; $y++)
    {
        for($x = 0; $x -lt $puzzleX; $x++)
        {
            if(!$octopusArray[$x,$y].flashed -and $octopusArray[$x,$y].power -gt 9)
            {
                $octopusArray[$x,$y].flashed = $true
                if($x+1 -lt $puzzleX){($octopusArray[($x+1),$y]).power++}
                if($x+1 -lt $puzzleX -and $y+1 -lt $puzzleY){($octopusArray[($x+1),($y+1)]).power++}
                if($y+1 -lt $puzzleY){($octopusArray[$x,($y+1)]).power++}
                if($y+1 -lt $puzzleY -and $x-1 -ge 0){($octopusArray[($x-1),($y+1)]).power++}
                if($x-1 -ge 0){($octopusArray[($x-1),$y]).power++}
                if($y-1 -ge 0 -and $x-1 -ge 0){($octopusArray[($x-1),($y-1)]).power++}
                if($y-1 -ge 0){($octopusArray[$x,($y-1)]).power++}
                if($x+1 -lt $puzzleX -and $y-1 -ge 0){($octopusArray[($x+1),($y-1)]).power++}
                FlashOctopuses $octopusArray
            }
        }
    }
}

function ResetFlashes($octopusArray)
{
    $flashes = 0
    foreach($octopus in $octopusArray.Where({$_.power -gt 9}))
    {
        $flashes++
        $octopus.flashed = $false
        $octopus.power = 0
    }
    $flashes
}

$totalFlashes = 0
for($i = 1; $i -le 100; $i++)
{
    IncreaseEnergy $octopuses
    FlashOctopuses $octopuses
    $totalFlashes += ResetFlashes $octopuses
}
$totalFlashes
