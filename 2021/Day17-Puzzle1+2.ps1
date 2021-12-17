## This could likely be cleaned up a lot
## It works though and is fairly quick by reducing
## the valid X sets and testing Y until there are
## no more valid Y sets to test (see lines 138-140)
$puzzleInput = "target area: x=79..137, y=-176..-117"
#$puzzleInput = "target area: x=20..30, y=-10..-5"

$targets = $puzzleInput.Replace("target area: ","")
$xZoneRange = Invoke-Expression ($targets.Split(",")[0].Replace("x=",""))
$yZoneRange = Invoke-Expression ($targets.Split(",")[1].Replace("y=","")) # weird that this expressed bottom to top, but okay

# Calculate valid X velocities
$xValidV = @{}
$xMaxV = $xZoneRange[-1] # don't overshoot it in one step!

#### add a min steps and max steps for $xValidV
#### this has the added benefit of reducing the number of steps you have to test each y
#### just remember that if Xvel = 0 and you're in range, there will be infinite steps
:xn for($xn = $xMaxV; $xn -gt 0; $xn--)
{
    $xPos = 0
    $xSteps = 0
    $xValidSteps = @()
    $firstHit = $true
    for($xv = $xn; $xv -ge 0; $xv--)
    {
        if($xn -eq 7)
        {
            $xn = 7
        }
        $xSteps++
        $xPos += $xv
        
        if($xPos -in $xZoneRange)
        {
            
            if($firstHit)
            {
                $xValidV.Add($xn, @($xSteps, $xSteps))
                $firstHit = $false
            }
            else
            {
                $xValidV[$xn] = @(($xValidV[$xn])[0], $xSteps) # keep the minimum step required to get
                                                               # to the zone, but add the new step as
                                                               # the maximum steps to be within the zone
            }

            # if the velocity is zero, and we're in range
            # then x will continue be in $xRange forever
            if($xv -eq 0)
            {
                $xValidV[$xn] = @(($xValidV[$xn])[0], [int]::MaxValue)
                continue xn # we're not going any further forward, no need to keep testing
            }  
        }
        if($xPos -gt $xZoneRange[-1])
        {
            continue xn # we overshot it Scotty!
        }
    }
}

# Y minimum velocity
$yMinV = $yZoneRange[0] # dont't overshoot it in one step!

function CheckCoordinates($x,$y)
{
    return ($x -in $xZoneRange -and $y -in $yZoneRange)
}

$yMaxHeight = 0
$totalValidCoordinates = 0
foreach($xV in $xValidV.Keys) # take each valid X velocity
{
    $initialYVelocity = $yMinV
    :ny while($true)
    {
        $xPos = 0
        $yPos = 0
        $xVelocity = $xV
        $yVelocity = $initialYVelocity
        $yMaxHeightThisRound = 0
        
        # get $yPos after minimum steps
        # we know it takes at least this many 
        # steps for X to reach the target zone
        for($s = 1; $s -le ($xValidV[$xV])[0]; $s++)
        {
            $xPos += $xVelocity
            $yPos += $yVelocity
            
            # track highest Y value
            if($yPos -gt $yMaxHeightThisRound){$yMaxHeightThisRound = $yPos}
            
            # increase/decrease velocity
            if($xVelocity -gt 0){$xVelocity--}
            $yVelocity--
        }
        if(CheckCoordinates $xPos $yPos)
        {
            ## we found a valid coordinate
            $initialYVelocity++ # next round we check a higher initial Y velocity
            $totalValidCoordinates++

            # if we have a new max height, add it!
            if($yMaxHeightThisRound -gt $yMaxHeight){$yMaxHeight = $yMaxHeightThisRound}
            continue ny
        }
        
        # Check the remaining valid X steps
        for($s = (($xValidV[$xV])[0])+1; $s -le ($xValidV[$xV])[1]; $s++)
        {
            $xPos += $xVelocity
            $yPos += $yVelocity

            # If y less than bottom of zone, we overshot it
            if($yPos -lt $yZoneRange[0])
            {
                $initialYVelocity++
                continue ny
            }

            # track highest Y value
            if($yPos -gt $yMaxHeightThisRound){$yMaxHeightThisRound = $yPos}

            if(CheckCoordinates $xPos $yPos)
            {
                ## we found a valid coordinate
                $initialYVelocity++ # next round we check a higher initial Y velocity
                $totalValidCoordinates++

                # if we have a new max height, add it!
                if($yMaxHeightThisRound -gt $yMaxHeight){$yMaxHeight = $yMaxHeightThisRound}
                continue ny
            }

            # Y ALWAYS reaches back to zero (it's a flat top parabola starting at 0)
            # So if we reach zero, and we're going to exceed the bottom of the range
            # no further Y velocity will be valid
            if($yPos -eq 0 -and ($yPos+$yVelocity) -lt $yZoneRange[0])
            {
                break ny
            }

            # increase/decrease velocity
            if($xVelocity -gt 0){$xVelocity--}
            $yVelocity--
        }

        # If y less than bottom of zone, we overshot it
        if($yPos -lt $yZoneRange[0])
        {
            $initialYVelocity++
            continue ny
        }
        # If y greater than top of zone, we will overshoot it
        if($yPos -gt $yZoneRange[-1])
        {
            break ny
        }
        $initialYVelocity++
    }
}
"Max Y Height: $yMaxHeight"
"Total Valid Coordinates: $totalValidCoordinates"
