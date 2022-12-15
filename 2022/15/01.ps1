$puzzleInput = Get-Content $PSScriptRoot\input.txt

class Sensor {
    [int]$x
    [int]$y
    [Beacon]$closestBeacon
    Sensor($x,$y,$beacon)
    {
        $this.x = $x
        $this.y = $y
        $this.closestBeacon = $beacon
    }

    [System.Array] GetIntersectionPointsForLine([int]$line)
    {
        $distanceToBeacon = $this.GetDistanceToBeacon()
        $yTop = $this.y - $distanceToBeacon
        $yBottom = $this.y + $distanceToBeacon
        if($line -lt $yTop -or $line -gt $yBottom)
        {
            return @()
        }
        else
        {
            ## get distance from y to line
            $yTravel = [Math]::Abs($this.y - $line)
            $xTravel = $distanceToBeacon - $yTravel

            ## get X intersection points
            $xLeft = $this.x - $xTravel
            $xRight = $this.x + $xTravel
            return @($xLeft,$xRight)
        }
    }

    hidden [int] GetDistanceToBeacon()
    {
        $xDistance = [Math]::Abs($this.x - $this.closestBeacon.x)
        $yDistance = [Math]::Abs($this.y - $this.closestBeacon.y)
        return $xDistance + $yDistance
    }
}

class Beacon {
    [int]$x
    [int]$y
    Beacon($x,$y)
    {
        $this.x = $x
        $this.y = $y
    }
}

$sensors = [System.Collections.Generic.List[Sensor]]@()
$beacons = [System.Collections.Generic.List[Beacon]]@()

$regX = [regex]::new('(x=(-?\d*))')
$regY = [regex]::new('(y=(-?\d*))')
foreach($i in $puzzleInput)
{
    $sensorText, $beaconText = $i -split ": "

    [int]$sensorX = $regX.Matches($sensorText).Groups[2].Value
    [int]$sensorY = $regY.Matches($sensorText).Groups[2].Value
    [int]$beaconX = $regX.Matches($beaconText).Groups[2].Value
    [int]$beaconY = $regY.Matches($beaconText).Groups[2].Value

    $beacon = [Beacon]::new($beaconX,$beaconY)
    [void]$beacons.Add($beacon)
    [void]$sensors.Add([Sensor]::new($sensorX,$sensorY,$beacon))
}

## this is bruteforcy... but I want to see part 2
$coveredPoints = [System.Collections.Generic.List[Int]]@()
$testLine = 2000000
foreach($s in $sensors)
{
    $range = $s.GetIntersectionPointsForLine($testLine)
    if($range.Count -gt 0)
    {
        [int[]]$range = $range[0]..$range[1]
        [void]$coveredPoints.AddRange($range)
    }
}

$coveredPoints = [System.Linq.Enumerable]::Distinct($coveredPoints).ToList()
foreach($b in $beacons.Where({$_.y -eq $testLine}))
{
    if($b.x -in $coveredPoints){[void]$coveredPoints.Remove(($b.x))}
}
[System.Linq.Enumerable]::Count($coveredPoints)