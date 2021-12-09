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
$directions = @("N","S","E","W")
for($i = 0; $i -lt $puzzleY; $i++)
{
    for($j = 0; $j -lt $puzzleX; $j++)
    {
        $lowSpot = $true
        foreach($direction in $directions)
        {
            if($null -ne $mapArray[$j,$i].$direction -and $mapArray[$j,$i].Value -ge $mapArray[$j,$i].$direction)
            {
                $lowSpot = $false
                break
            }
        }
        if($lowSpot)
        {
            $lowSpotsRisk += $mapArray[$j,$i].Value
            $lowSpotCount++
        }
    }
}
$lowSpotsRisk+$lowSpotCount
