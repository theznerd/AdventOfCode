$ErrorActionPreference = "Continue"
$puzzleInput = Get-Content 'C:\Users\Nathan Ziehnert\OneDrive - Z-Nerd\Documents\AOC\2021\09\input.txt'
#$puzzleInput = Get-Content 'C:\Users\Nathan Ziehnert\OneDrive - Z-Nerd\Documents\AOC\2021\09\test-input.txt'

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

# Find Low spots
$lowSpotsRisk = 0
$lowSpotCount = 0
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
                    $lowSpotsRisk += $mapArray[$j,$i].Value
                    $lowSpotCount++
                }
            }
            elseif($i -eq 0 -and $j -gt 0)
            {
                #top right
                if($mapArray[$j,$i].Value -lt $mapArray[$j,$i].W -and $mapArray[$j,$i].Value -lt $mapArray[$j,$i].S)
                {
                    $lowSpotsRisk += $mapArray[$j,$i].Value
                    $lowSpotCount++
                }
            }
            elseif($i -gt 0 -and $j -eq 0)
            {
                #bottom left
                if($mapArray[$j,$i].Value -lt $mapArray[$j,$i].E -and $mapArray[$j,$i].Value -lt $mapArray[$j,$i].N)
                {
                    $lowSpotsRisk += $mapArray[$j,$i].Value
                    $lowSpotCount++
                }
            }
            else
            {
                #bottom right
                if($mapArray[$j,$i].Value -lt $mapArray[$j,$i].W -and $mapArray[$j,$i].Value -lt $mapArray[$j,$i].N)
                {
                    $lowSpotsRisk += $mapArray[$j,$i].Value
                    $lowSpotCount++
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
                    $lowSpotsRisk += $mapArray[$j,$i].Value
                    $lowSpotCount++
                }
            }
            else
            {
                #bottom of map
                if($mapArray[$j,$i].Value -lt $mapArray[$j,$i].W -and $mapArray[$j,$i].Value -lt $mapArray[$j,$i].E -and $mapArray[$j,$i].Value -lt $mapArray[$j,$i].N)
                {
                    $lowSpotsRisk += $mapArray[$j,$i].Value
                    $lowSpotCount++
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
                    $lowSpotsRisk += $mapArray[$j,$i].Value
                $lowSpotCount++
                }

            }
            else
            {
                #map right
                if($mapArray[$j,$i].Value -lt $mapArray[$j,$i].W -and $mapArray[$j,$i].Value -lt $mapArray[$j,$i].N -and $mapArray[$j,$i].Value -lt $mapArray[$j,$i].S)
                {
                    $lowSpotsRisk += $mapArray[$j,$i].Value
                $lowSpotCount++
                }
            }
        }
        
        else
        {
            # read all sides
            if($mapArray[$j,$i].Value -lt $mapArray[$j,$i].W -and $mapArray[$j,$i].Value -lt $mapArray[$j,$i].E -and $mapArray[$j,$i].Value -lt $mapArray[$j,$i].N -and $mapArray[$j,$i].Value -lt $mapArray[$j,$i].S)
            {
                $lowSpotsRisk += $mapArray[$j,$i].Value
                $lowSpotCount++
            }
        }
    }
}
$lowSpotsRisk+$lowSpotCount
