$puzzleInput = Get-Content 'C:\Users\Nathan Ziehnert\OneDrive - Z-Nerd\Documents\AOC\2021\09\input.txt'

$puzzleX = $puzzleInput[0].ToCharArray().Count
$puzzleY = $puzzleInput.Count
$mapArray = New-Object 'object[,]' $puzzleX,$puzzleY

# Build Map Array
for($i = 0; $i -lt $puzzleY; $i++)
{
    for($j = 0; $j -lt $puzzleX; $j++)
    {
        if($i -eq 0){$N = $null}else{$N = [int]::Parse(($puzzleInput[$i-1].ToCharArray())[$j])}
        if($i -eq $puzzleY-1){$S = $null}else{$S = [int]::Parse(($puzzleInput[$i+1].ToCharArray())[$j])}
        if($j -eq 0){$W = $null}else{$W = [int]::Parse(($puzzleInput[$i].ToCharArray())[$j-1])}
        if($j -eq $puzzleX-1){$E = $null}else{$E = [int]::Parse(($puzzleInput[$i].ToCharArray())[$j+1])}
        $mapArray[$j,$i] = @{
            Value = $([int]::Parse(($puzzleInput[$i].ToCharArray())[$j]))
            N = $N
            E = $E
            S = $S
            W = $W
        }
    }
}

function GetBasin($x, $y)
{
    $coordinates = @()
    $coordinates += @{name="$x$y";x=$x;y=$y}
    if($mapArray[$x,$y].N -ne $null -and $mapArray[$x,$y].Value -lt $mapArray[$x,$y].N -and $mapArray[$x,$y].N -ne 9)
    {
        $newCoordinates = GetBasin $x ($y-1)
        foreach($nc in $newCoordinates){if($nc.Name -notin $coordinates.name){$coordinates += $nc}}
    }
    if($mapArray[$x,$y].S -ne $null -and $mapArray[$x,$y].Value -lt $mapArray[$x,$y].S -and $mapArray[$x,$y].S -ne 9)
    {
        $newCoordinates = GetBasin $x ($y+1)
        foreach($nc in $newCoordinates){if($nc.Name -notin $coordinates.name){$coordinates += $nc}}
    }
    if($mapArray[$x,$y].E -ne $null -and $mapArray[$x,$y].Value -lt $mapArray[$x,$y].E -and $mapArray[$x,$y].E -ne 9)
    {
        $newCoordinates = GetBasin ($x+1) $y
        foreach($nc in $newCoordinates){if($nc.Name -notin $coordinates.name){$coordinates += $nc}}
    }
    if($mapArray[$x,$y].W -ne $null -and $mapArray[$x,$y].Value -lt $mapArray[$x,$y].W -and $mapArray[$x,$y].W -ne 9)
    {
        $newCoordinates = GetBasin ($x-1) $y
        foreach($nc in $newCoordinates){if($nc.Name -notin $coordinates.name){$coordinates += $nc}}
    }
    return $coordinates
}

# Find Low spots
$lowSpots = @() #Coordinates
for($i = 0; $i -lt $puzzleY; $i++)
{
    for($j = 0; $j -lt $puzzleX; $j++)
    {
        if(($j -eq 0 -or $j -eq $puzzleX-1) -and ($i -eq 0 -or $i -eq $puzzleY))
        {
            if($i -eq 0 -and $j -eq 0)
            {
                #top left
                if($mapArray[$j,$i].Value -lt $mapArray[$j,$i].E -and $mapArray[$j,$i].Value -lt $mapArray[$j,$i].S)
                {
                    $lowSpots += @{x=$j;y=$i}
                }
            }
            elseif($i -eq 0 -and $j -gt 0)
            {
                #top right
                if($mapArray[$j,$i].Value -lt $mapArray[$j,$i].W -and $mapArray[$j,$i].Value -lt $mapArray[$j,$i].S)
                {
                    $lowSpots += @{x=$j;y=$i}
                }
            }
            elseif($i -gt 0 -and $j -eq 0)
            {
                #bottom left
                if($mapArray[$j,$i].Value -lt $mapArray[$j,$i].E -and $mapArray[$j,$i].Value -lt $mapArray[$j,$i].N)
                {
                    $lowSpots += @{x=$j;y=$i}
                }
            }
            else
            {
                #bottom right
                if($mapArray[$j,$i].Value -lt $mapArray[$j,$i].W -and $mapArray[$j,$i].Value -lt $mapArray[$j,$i].N)
                {
                    $lowSpots += @{x=$j;y=$i}
                }
            }
        }
        elseif($i -eq 0 -or $i -eq $puzzleY-1)
        {
            if($i -eq 0)
            {
                #top of map
                if($mapArray[$j,$i].Value -lt $mapArray[$j,$i].W -and $mapArray[$j,$i].Value -lt $mapArray[$j,$i].E -and $mapArray[$j,$i].Value -lt $mapArray[$j,$i].S)
                {
                    $lowSpots += @{x=$j;y=$i}
                }
            }
            else
            {
                #bottom of map
                if($mapArray[$j,$i].Value -lt $mapArray[$j,$i].W -and $mapArray[$j,$i].Value -lt $mapArray[$j,$i].E -and $mapArray[$j,$i].Value -lt $mapArray[$j,$i].N)
                {
                    $lowSpots += @{x=$j;y=$i}
                }
            }
        }
        elseif($j -eq 0 -or $j -eq $puzzleX-1)
        {
            if($j -eq 0)
            {
                #map left
                if($mapArray[$j,$i].Value -lt $mapArray[$j,$i].E -and $mapArray[$j,$i].Value -lt $mapArray[$j,$i].N -and $mapArray[$j,$i].Value -lt $mapArray[$j,$i].S)
                {
                    $lowSpots += @{x=$j;y=$i}
                }

            }
            else
            {
                #map right
                if($mapArray[$j,$i].Value -lt $mapArray[$j,$i].W -and $mapArray[$j,$i].Value -lt $mapArray[$j,$i].N -and $mapArray[$j,$i].Value -lt $mapArray[$j,$i].S)
                {
                    $lowSpots += @{x=$j;y=$i}
                }
            }
        }
        else
        {
            # read all sides
            if($mapArray[$j,$i].Value -lt $mapArray[$j,$i].W -and $mapArray[$j,$i].Value -lt $mapArray[$j,$i].E -and $mapArray[$j,$i].Value -lt $mapArray[$j,$i].N -and $mapArray[$j,$i].Value -lt $mapArray[$j,$i].S)
            {
                $lowSpots += @{x=$j;y=$i}
            }
        }
    }
}

#Find basins
$basinSizes = @()
foreach($lowSpot in $lowSpots)
{
    $basinSizes += (GetBasin $lowSpot['x'] $lowSpot['y']).Count
}
($basinSizes | sort -Descending)[0]*($basinSizes | sort -Descending)[1]*($basinSizes | sort -Descending)[2]
