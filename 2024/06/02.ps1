#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

class Guard {
    [int]$positionX = 0
    [int]$positionY = 0
    $direction = "up"
}

class MapPosition {
    [int]$X = 0
    [int]$Y = 0
    [string]$value
    [string]$testValue
    [string[]]$testDirections = @()
    MapPosition($x, $y, $value) {
        $this.X = $x
        $this.Y = $y
        $this.value = $value
        $this.testValue = $value
    }
}

# Map Puzzle
$GuardStart = @()
$Guard = [Guard]::new()
$puzzleHash = @{}

$mapTop = 0
$mapBottom = $puzzleInput.Count - 1
$mapLeft = 0
$mapRight = $puzzleInput[0].Length - 1

for($y = 0; $y -lt $puzzleInput.Count; $y++){
    for($x = 0; $x -lt $puzzleInput[0].Length; $x++){
        $puzzleHash.Add("$x,$y",[MapPosition]::new($x, $y, $puzzleInput[$y][$x]))
        switch ($puzzleInput[$y][$x]){
            '^' {$Guard.positionX = $x; $Guard.positionY = $y; $GuardStart = @($x,$y,"up"); $Guard.direction = "up"}
            '>' {$Guard.positionX = $x; $Guard.positionY = $y; $GuardStart = @($x,$y,"right"); $Guard.direction = "right"}
            '<' {$Guard.positionX = $x; $Guard.positionY = $y; $GuardStart = @($x,$y,"left"); $Guard.direction = "left"}
            'v' {$Guard.positionX = $x; $Guard.positionY = $y; $GuardStart = @($x,$y,"down"); $Guard.direction = "down"}
        }
    }
}

$blockedAt = [System.Collections.Generic.List[object]]::new()
While($Guard.positionY -ge $mapTop -and 
      $Guard.positionY -le $mapBottom -and
      $Guard.positionX -ge $mapLeft -and
      $Guard.positionX -le $mapRight)
{
    # Poop an X
    $puzzleHash["$($Guard.positionX),$($Guard.PositionY)"].value = "X"

    # Check next space
    $blocked = $false
    $gx = $Guard.PositionX
    $gy = $Guard.PositionY

    switch ($Guard.direction){
        "up" {
            if($puzzleHash["$($Guard.positionX),$($Guard.PositionY-1)"].value -eq "#"){
                $blockedAt.Add(@($($Guard.positionX),$($Guard.PositionY), $guard.direction, $puzzleHash.Values.Where({$_.value -eq "X"})))
                $Guard.direction = "right" 
                $blocked = $true;
            }}
        "right" {
            if($puzzleHash["$($Guard.positionX+1),$($Guard.PositionY)"].value -eq "#"){
                $blockedAt.Add(@($($Guard.positionX),$($Guard.PositionY), $guard.direction, $puzzleHash.Values.Where({$_.value -eq "X"})))
                $Guard.direction = "down" 
                $blocked = $true
            }}
        "left" {
            if($puzzleHash["$($Guard.positionX-1),$($Guard.PositionY)"].value -eq "#"){
                $blockedAt.Add(@($($Guard.positionX),$($Guard.PositionY), $guard.direction, $puzzleHash.Values.Where({$_.value -eq "X"})))
                $Guard.direction = "up"
                $blocked = $true
            }}
        "down" {
            if($puzzleHash["$($Guard.positionX),$($Guard.PositionY+1)"].value -eq "#"){
                $blockedAt.Add(@($($Guard.positionX),$($Guard.PositionY), $guard.direction, $puzzleHash.Values.Where({$_.value -eq "X"})))
                $Guard.direction = "left"
                $blocked = $true
            }}
    }

    if(!$blocked){
        switch ($Guard.direction){
            "up"    {$guard.PositionY--}
            "right" {$guard.PositionX++}
            "left"  {$guard.PositionX--}
            "down"  {$guard.PositionY++}
        }
    }
}

## Tests for obstacles in the rectangle
#  If there are obstacles in the path of the rectangle
#  then this will return false
function Test-Rectangle ($t, $r, $b, $l){
    if($puzzleHash.Values.Where({($_.x -ge $t.X -and $_.x -lt ($r.X-1) -and $_.y -eq ($t.y+1)) -and $_.value -eq "#"}) -or #top-left to top-right
       $puzzleHash.Values.Where({($_.y -ge $r.Y -and $_.y -lt ($b.Y-1) -and $_.x -eq ($r.x-1)) -and $_.value -eq "#"}) -or #top-right to bottom-right
       $puzzleHash.Values.Where({($_.x -gt ($l.X+1) -and $_.x -lt $r.X -and $_.y -eq ($b.y-1)) -and $_.value -eq "#"}) -or #bottom-right to bottom-left
       $puzzleHash.Values.Where({($_.y -gt ($t.Y+1) -and $_.y -lt $b.Y -and $_.x -eq ($l.x+1)) -and $_.value -eq "#"})     #bottom-left to top-right
    ){return $false}else{return $true}
}

function Print-TestMap {
    for($y = 0; $y -le $mapBottom; $y++){
        Write-Host "$(($puzzleHash.Values.Where({$_.y -eq $y}) | Sort-Object X).testValue -join '')"
    }
    Write-Host "-----------------------"
}

function Test-NewMap ($newObstacle) {
    # Reset Map
    $Guard.positionX = $GuardStart[0]
    $Guard.positionY = $GuardStart[1]
    $Guard.direction = $GuardStart[2]
    foreach($v in $puzzleHash.Values.Where({$_.testvalue -eq "X" -or $_.testvalue -eq "N"})){
        $v.testValue = "."
        $v.testDirections = @()
    }
    $puzzleHash["$($newObstacle.X),$($newObstacle.Y)"].testValue = "N"

    While($Guard.positionY -ge $mapTop -and 
          $Guard.positionY -le $mapBottom -and
          $Guard.positionX -ge $mapLeft -and
          $Guard.positionX -le $mapRight)
    {
        #Print-TestMap
        # Check next space
        $blocked = $false
        $gx = $Guard.PositionX
        $gy = $Guard.PositionY

        # Check guard position - is it X and are we visiting it
        # in a direction we've already come? Then we're in a loop
        if($puzzleHash["$gx,$gy"].testValue -eq "X" -and
            $Guard.direction -in $puzzleHash["$gx,$gy"].testDirections){
            return $true
        }

        switch ($Guard.direction){
            "up" {
                if($puzzleHash["$($gx),$($gy-1)"].testvalue -in @("#","N")){
                    $Guard.direction = "right" 
                    $blocked = $true;
                }
            }
            "right" {
                if($puzzleHash["$($gx+1),$($gy)"].testvalue -in @("#","N")){
                    $Guard.direction = "down" 
                    $blocked = $true
                }
            }
            "left" {
                if($puzzleHash["$($gx-1),$($gy)"].testvalue -in @("#","N")){
                    $Guard.direction = "up"
                    $blocked = $true
                }
            }
            "down" {
                if($puzzleHash["$($gx),$($gy+1)"].testvalue -in @("#","N")){
                    $Guard.direction = "left"
                    $blocked = $true
                }
            }
        }

        if(!$blocked){
            $puzzleHash["$($gx),$($gy)"].testValue = "X"
            if($guard.direction -notin $puzzleHash["$($gx),$($gy)"].testDirections){$puzzleHash["$($gx),$($gy)"].testDirections += $guard.direction}
            switch ($Guard.direction){
                "up"    {$guard.PositionY--}
                "right" {$guard.PositionX++}
                "left"  {$guard.PositionX--}
                "down"  {$guard.PositionY++}
            }
        }
    }
    return $false
}

$validBlocks = @()
$invalidBlocks = @()
$i = 1
:loopFinder foreach($stop in $blockedAt)
{
    Write-Host "Testing Blocked At $i of $($blockedAt.count)"
    $i++
    $x, $y, $direction, $pathsVisited = $stop
    ## We know that for it to be a valid loop from
    ## this stopping point, it requires that the path
    ## touch some point we've already visited in the
    ## same direction we visited it

    ## We also know that we cannot place an obstacle
    ## on path that has already been traveled

    ## However, the obstacle must be placed on a path
    ## that you will EVENTUALLY traverse
    
    ## Additionally we know that we can only place
    ## obstacles to 90*CW to the current stop position
    ## e.g. you can only place an obstacle to the left
    ## if you were facing down. 

    $possibleNewObstacles = @()
    switch($direction){
        "up"{
            # Get all positions to the right that we could add a block
            $positionsRight = $puzzleHash.Values.Where({$_.x -gt $x -and $_.y -eq $y -and ($_.value -eq "X" -or $_.value -eq "#") -and "$($_.x),$($_.y)" -notin $pathsVisited}) | Sort-Object X
            $lastFreeSpace = $positionsRight.value.IndexOf("#")-1
            if($lastFreeSpace -ge 0){
                $positionsRight = $positionsRight[0..$lastFreeSpace]
            }
            # Now when adding the blocker, it must eventually run into a blocker...
            # only keep $positionsRight where after going 90 degrees there will be
            # a blocker down
            foreach($p in $positionsRight){
                if($puzzleHash.Values.Where({$_.x -eq $p.X-1 -and $_.y -gt $p.Y -and $_.value -eq "#"})){
                    $possibleNewObstacles += $p
                }
            }
        }
        "right"{
            # Get all positions down that we could add a block
            $positionsDown = $puzzleHash.Values.Where({$_.x -eq $x -and $_.y -gt $y -and ($_.value -eq "X" -or $_.value -eq "#") -and "$($_.x),$($_.y)" -notin $pathsVisited}) | Sort-Object Y
            $lastFreeSpace = $positionsDown.value.IndexOf("#")-1
            if($lastFreeSpace -ge 0){
                $positionsDown = $positionsDown[0..$lastFreeSpace]
            }
            # Now when adding the blocker, it must eventually run into a blocker...
            # only keep $positionsDown where after going 90 degrees there will be
            # a blocker left
            foreach($p in $positionsDown){
                if($puzzleHash.Values.Where({$_.x -lt $p.X -and $_.y -eq $p.Y-1 -and $_.value -eq "#"})){
                    $possibleNewObstacles += $p
                }
            }
        }
        "down"{
            # Get all positions to the right that we could add a block
            $positionsLeft = $puzzleHash.Values.Where({$_.x -lt $x -and $_.y -eq $y -and ($_.value -eq "X" -or $_.value -eq "#") -and "$($_.x),$($_.y)" -notin $pathsVisited}) | Sort-Object X -Descending
            $lastFreeSpace = $positionsLeft.value.IndexOf("#")-1
            if($lastFreeSpace -ge 0){
                $positionsLeft = $positionsLeft[0..$lastFreeSpace]
            }
            # Now when adding the blocker, it must eventually run into a blocker...
            # only keep $positionsLeft where after going 90 degrees there will be
            # a blocker up
            foreach($p in $positionsLeft){
                if($puzzleHash.Values.Where({$_.x -eq $p.X+1 -and $_.y -lt $p.Y -and $_.value -eq "#"})){
                    $possibleNewObstacles += $p
                }
            }
        }
        "left"{
            # Get all positions up that we could add a block
            $positionsUp = $puzzleHash.Values.Where({$_.x -eq $x -and $_.y -lt $y -and ($_.value -eq "X" -or $_.value -eq "#") -and "$($_.x),$($_.y)" -notin $pathsVisited}) | Sort-Object Y -Descending
            $lastFreeSpace = $positionsUp.value.IndexOf("#")-1
            if($lastFreeSpace -ge 0){
                $positionsUp = $positionsUp[0..$lastFreeSpace]
            }
            # Now when adding the blocker, it must eventually run into a blocker...
            # only keep $positionsUp where after going 90 degrees there will be
            # a blocker right
            foreach($p in $positionsUp){
                if($puzzleHash.Values.Where({$_.x -gt $p.X -and $_.y -eq $p.Y+1 -and $_.value -eq "#"})){
                    $possibleNewObstacles += $p
                }
            }
        }
    }
    # Test Obstacles
    foreach($obstacle in $possibleNewObstacles){
        if($obstacle -in $invalidBlocks -or $obstacle -in $validBlocks){
            continue # we already tested this for a loop
        }
        elseif(Test-NewMap $obstacle){
            $validBlocks += $obstacle
        }else {
            $invalidBlocks += $obstacle
        }
    }
}
$validBlocks.Count