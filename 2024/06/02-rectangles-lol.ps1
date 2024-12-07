$puzzleInput = Get-Content $PSScriptRoot\example.txt
#$puzzleInput = Get-Content $PSScriptRoot\input.txt

class Guard {
    [int]$positionX = 0
    [int]$positionY = 0
    $direction = "up"
}

class MapPosition {
    [int]$X = 0
    [int]$Y = 0
    [string]$value
    MapPosition($x, $y, $value) {
        $this.X = $x
        $this.Y = $y
        $this.value = $value
    }
}

# Map Puzzle
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
            '^' {$Guard.positionX = $x; $Guard.positionY = $y; $Guard.direction = "up"}
            '>' {$Guard.positionX = $x; $Guard.positionY = $y; $Guard.direction = "right"}
            '<' {$Guard.positionX = $x; $Guard.positionY = $y; $Guard.direction = "left"}
            'v' {$Guard.positionX = $x; $Guard.positionY = $y; $Guard.direction = "down"}
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
                ## FOR LATER? .ForEach({"$($_.X),$($_.Y)"})
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

$validRectangles = @()
:rectangleFinder foreach($stop in $blockedAt)
{
    $x, $y, $direction, $pathsVisited = $stop
    switch ($direction) {
        "up" {
            $top = $puzzleHash["$x,$($y-1)"]
            $right = $puzzleHash.Values.Where({$_.x -gt $x -and $_.y -eq $y -and $_.value -eq "#"}) | Sort-Object X # Only get the first one you'd run into
            $right = if($right){$right[0]}else{$null}
            $lefts = $puzzleHash.Values.Where({$_.x -eq $x-1 -and $_.y -gt $y -and $_.value -eq "#"})
            
            if(!$right -and !$lefts.Count){
                # we should have at least a valid bottom-left or top-right,
                # obstacle, otherwise we'd have to add 2 obstacles
                continue rectangleFinder
            }
            elseif(!$right){
                # if we only have bottom-left obstacles, are there any
                # bottom-right obstacles that would lead us to them?
                foreach($left in $lefts){
                    $bottoms = $puzzleHash.Values.Where({$_.x -ge ($left.X+1) -and $_.y -eq $left.Y+1 -and $_.value -eq "#"}) | Sort-Object Y
                    if(!$bottoms){continue}
                    else{
                        foreach($bottom in $bottoms){
                            $right = $puzzleHash["$($bottom.x+1),$($y)"] # get the matching point for the top-right
                            if($right -in $pathsVisited){continue} # we can't have previously visited this path
                            else{
                                if(Test-Rectangle $top $right $bottom $left)
                                {$validRectangles += ,@($top, $right, $bottom, $left)}
                            }    
                        }
                    }    
                }
            }
            elseif(!$lefts.Count -eq 0){
                # if we only have top-right obstacles, are there any
                # bottom-right obstacles we'll run into?
                $bottom = $puzzleHash.Values.Where({$_.x -eq ($right.X-1) -and $_.y -ge $right.Y -and $_.value -eq "#"}) | Sort-Object Y
                if(!$bottom){continue}
                else{
                    $bottom = $bottom[0] # has to be the first obstacle - cannot bypass an obstacle
                    $left = $puzzleHash["$($x-1),$($bottom.Y-1)"] # get the matching point for the bottom-left
                    if($left -in $pathsVisited){continue} # we can't have previously visited this path
                    else{
                        if(Test-Rectangle $top $right $bottom $left)
                        {$validRectangles += ,@($top, $right, $bottom, $left)}
                    }
                }
            }if($right -and $lefts.Count){
                # if both top-right and bottom-lefts
                # we should test all bottom-lefts for their matching bottom-right
                foreach($left in $lefts){
                    $bottom = $puzzleHash["$($right.X-1),$($left.Y+1)"] # only one bottom per valid right+left pair
                    if($bottom -in $pathsVisited){continue} # we can't have previously visited this path, otherwise we'd have hit this obstacle before
                    else{
                        if(Test-Rectangle $top $right $bottom $left)
                        {$validRectangles += ,@($top, $right, $bottom, $left)}
                    }
                }
            }
        }
        "right" {
            $right = $puzzleHash["$($x+1),$y"]
            $bottom = $puzzleHash.Values.Where({$_.y -gt $y -and $_.x -eq $x -and $_.value -eq "#"}) | Sort-Object X # Only get the first one you'd run into
            $bottom = if($bottom){$bottom[0]}else{$null}
            $tops = $puzzleHash.Values.Where({$_.y -eq $y-1 -and $_.x -lt $x -and $_.value -eq "#"})
            
            if(!$bottom -and !$tops.Count){
                # we should have at least a valid top-left or bottom-right,
                # obstacle, otherwise we'd have to add 2 obstacles
                continue rectangleFinder
            }
            elseif(!$bottom){
                # if we only have top-left obstacles, are there any
                # bottom-left obstacles that would lead us to them?
                foreach($top in $tops){
                    $lefts = $puzzleHash.Values.Where({$_.y -ge ($top.y+1) -and $_.x -eq $top.x-1 -and $_.value -eq "#"})
                    if(!$lefts){continue}
                    else{
                        foreach($left in $lefts){
                            $bottom = $puzzleHash["$($x),$($left.y+1)"] # get the matching point for the bottom-right
                            if($right -in $pathsVisited){continue} # we can't have previously visited this path
                            else{
                                if(Test-Rectangle $top $right $bottom $left)
                                {$validRectangles += ,@($top, $right, $bottom, $left)}
                            }    
                        }
                    }    
                }
            }
            elseif(!$tops.Count){
                # if we only have bottom-right obstacles, are there any
                # bottom-left obstacles we'll run into?
                $left = $puzzleHash.Values.Where({$_.x -le ($bottom.X) -and $_.y -eq $bottom.Y-1 -and $_.value -eq "#"}) | Sort-Object Y
                if(!$left){continue}
                else{
                    $left = $left[0] # has to be the first obstacle - cannot bypass an obstacle
                    $top = $puzzleHash["$($left.x+1),$($y-1)"] # get the matching point for the top-left
                    if($top -in $pathsVisited){continue} # we can't have previously visited this path
                    else{
                        if(Test-Rectangle $top $right $bottom $left)
                        {$validRectangles += ,@($top, $right, $bottom, $left)}
                    }
                }
            }if($bottom -and $tops.Count){
                # if both bottom-right and top-lefts
                # we should test all top-lefts for their matching bottom-left
                foreach($top in $tops){
                    $left = $puzzleHash["$($top.X-1),$($bottom.Y-1)"] # only one bottom per valid pair
                    if($left -in $pathsVisited){continue} # we can't have previously visited this path, otherwise we'd have hit this obstacle before
                    else{
                        if(Test-Rectangle $top $right $bottom $left)
                        {$validRectangles += ,@($top, $right, $bottom, $left)}
                    }
                }
            }
        }
        "down" {
            $bottom = $puzzleHash["$x,$($y+1)"]
            $left = $puzzleHash.Values.Where({$_.x -le $x -and $_.y -eq $y -and $_.value -eq "#"}) | Sort-Object X -Descending # Only get the first one you'd run into
            $left = if($left){$left[0]}else{$null}
            $rights = $puzzleHash.Values.Where({$_.y -le $y -and $_.x -eq $x+1 -and $_.value -eq "#"})
            
            if(!$left -and !$rights.Count){
                # we should have at least a valid bottom-left or top-right,
                # obstacle, otherwise we'd have to add 2 obstacles
                continue rectangleFinder
            }
            elseif(!$left){
                # if we only have top-right obstacles, are there any
                # top-left obstacles that would lead us to them?
                foreach($right in $rights){
                    $tops = $puzzleHash.Values.Where({$_.y -eq ($right.y-1) -and $_.x -le $right.x-1 -and $_.value -eq "#"})
                    if(!$tops){continue}
                    else{
                        foreach($top in $tops){
                            $left = $puzzleHash["$($top.x-1),$($y)"] # get the matching point for the bottom-left
                            if($left -in $pathsVisited){continue} # we can't have previously visited this path
                            else{
                                if(Test-Rectangle $top $right $bottom $left)
                                {$validRectangles += ,@($top, $right, $bottom, $left)}
                            }    
                        }
                    }    
                }
            }
            elseif(!$rights.Count){
                # if we only have bottom-left obstacles, are there any
                # top-left obstacles we'll run into?
                $top = $puzzleHash.Values.Where({$_.x -eq ($left.X+1) -and $_.y -lt $y -and $_.value -eq "#"}) | Sort-Object Y -Descending
                if(!$top){continue}
                else{
                    $top = $top[0] # has to be the first obstacle - cannot bypass an obstacle
                    $right = $puzzleHash["$($x+1),$($top.y+1)"] # get the matching point for the top-right
                    if($right -in $pathsVisited){continue} # we can't have previously visited this path
                    else{
                        if(Test-Rectangle $top $right $bottom $left)
                        {$validRectangles += ,@($top, $right, $bottom, $left)}
                    }
                }
            }if($left -and $rights.Count){
                # if both bottom-left and top-rights
                # we should test all top-rights for their matching top-left
                foreach($right in $rights){
                    $top = $puzzleHash["$($left.X+1),$($right.Y-1)"] # only one bottom per valid pair
                    if($top -in $pathsVisited){continue} # we can't have previously visited this path, otherwise we'd have hit this obstacle before
                    else{
                        if(Test-Rectangle $top $right $bottom $left)
                        {$validRectangles += ,@($top, $right, $bottom, $left)}
                    }
                }
            }
        }
        "left" {
            $left = $puzzleHash["$($x-1),$y"]
            $top = $puzzleHash.Values.Where({$_.x -eq $x -and $_.y -le $y -and $_.value -eq "#"}) | Sort-Object Y -Descending # Only get the first one you'd run into
            $top = if($top){$top[0]}else{$null}
            $bottoms = $puzzleHash.Values.Where({$_.y -eq $y+1 -and $_.x -gt $x -and $_.value -eq "#"})
            
            if(!$top -and !$bottoms.Count){
                # we should have at least a valid top-left or bottom-right,
                # obstacle, otherwise we'd have to add 2 obstacles
                continue rectangleFinder
            }
            elseif(!$top){
                # if we only have bottom-right obstacles, are there any
                # top-right obstacles that would lead us to them?
                foreach($bottom in $bottoms){
                    $rights = $puzzleHash.Values.Where({$_.x -eq ($bottom.x+1) -and $_.y -lt $bottom.x -and $_.value -eq "#"})
                    if(!$rights){continue}
                    else{
                        foreach($right in $rights){
                            $top = $puzzleHash["$($x),$($right.y-1)"] # get the matching point for the top-left
                            if($top -in $pathsVisited){continue} # we can't have previously visited this path
                            else{
                                if(Test-Rectangle $top $right $bottom $left)
                                {$validRectangles += ,@($top, $right, $bottom, $left)}
                            }    
                        }
                    }    
                }
            }
            elseif(!$bottoms.Count){
                # if we only have top-left obstacles, are there any
                # top-right obstacles we'll run into?
                $right = $puzzleHash.Values.Where({$_.y -eq ($top.y+1) -and $_.x -gt $x -and $_.value -eq "#"}) | Sort-Object X
                if(!$right){continue}
                else{
                    $right = $right[0] # has to be the first obstacle - cannot bypass an obstacle
                    $bottom = $puzzleHash["$($right.x-1),$($y+1)"] # get the matching point for the bottom-right
                    if($bottom -in $pathsVisited){continue} # we can't have previously visited this path
                    else{
                        if(Test-Rectangle $top $right $bottom $left)
                        {$validRectangles += ,@($top, $right, $bottom, $left)}
                    }
                }
            }if($top -and $bottoms.Count){
                # if both top-left and bottom-rights
                # we should test all bottom-rights for their matching top-right
                foreach($bottom in $bottoms){
                    $right = $puzzleHash["$($bottom.X+1),$($top.Y+1)"] # only one bottom per valid pair
                    if($right -in $pathsVisited){continue} # we can't have previously visited this path, otherwise we'd have hit this obstacle before
                    else{
                        if(Test-Rectangle $top $right $bottom $left)
                        {$validRectangles += ,@($top, $right, $bottom, $left)}
                    }
                }
            }
        }
    }
}

$hashHack = @{}
foreach($validRectangle in $validRectangles)
{
    $obstacle = $validRectangle.Where({$_.Value -eq "X"})
    if(!$hashHack.ContainsKey("$($obstacle.X),$($obstacle.Y)")){$hashHack.Add("$($obstacle.X),$($obstacle.Y)","")}
}