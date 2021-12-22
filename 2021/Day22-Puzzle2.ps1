$puzzleInput = Get-Content 'C:\Users\Nathan Ziehnert\OneDrive - Z-Nerd\Documents\AOC\2021\22\input.txt'

Class Cuboid
{
    [bool]$on = $false
    [int]$x1
    [int]$x2
    [int]$y1
    [int]$y2
    [int]$z1
    [int]$z2
    [long]GetVolume()
    {
        return ($this.x2-$this.x1)*($this.y2-$this.y1)*($this.z2-$this.z1)
    }
    [Cuboid]Clone()
    {
        $newCuboid = [Cuboid]::new()
        $newCuboid.x1 = $this.x1
        $newCuboid.x2 = $this.x2
        $newCuboid.y1 = $this.y1
        $newCuboid.y2 = $this.y2
        $newCuboid.z1 = $this.z1
        $newCuboid.z2 = $this.z2
        $newCuboid.on = $this.on
        return $newCuboid
    }
}

function Get-OverlappingCoordinates($cuboidOne, $cuboidTwo)
{
    $a1,$a2,$b1,$b2,$c1,$c2 = @($cuboidTwo.x1,$cuboidTwo.x2,$cuboidTwo.y1,$cuboidTwo.y2,$cuboidTwo.z1,$cuboidTwo.z2)
    $x1,$x2,$y1,$y2,$z1,$z2 = @($cuboidOne.x1,$cuboidOne.x2,$cuboidOne.y1,$cuboidOne.y2,$cuboidOne.z1,$cuboidOne.z2)

    $d1,$d2,$e1,$e2,$f1,$f2 = @([Math]::Max($a1,$x1),[Math]::Min($a2,$x2),[Math]::Max($b1,$y1),[Math]::Min($b2,$y2),[Math]::Max($c1,$z1),[Math]::Min($c2,$z2))

    if($d2 -gt $d1 -and $e2 -gt $e1 -and $f2 -gt $f1)
    {
        return @{
            "x1" = $d1
            "x2" = $d2
            "y1" = $e1
            "y2" = $e2
            "z1" = $f1
            "z2" = $f2
        }
    }
    else
    {
        return $null # the cubes don't overlap
    }
}

function Get-ExplodedCuboids($cuboid, $overlappingCoordinates)
{
    $explodedCubes = [System.Collections.ArrayList]::new()
    $cuboidClone = $cuboid.Clone()
    
    ## take everything to the left
    $leftCuboid = [Cuboid]::New()
    $leftCuboid.x1 = $cuboidClone.x1
    $leftCuboid.x2 = $overlappingCoordinates["x1"]
    $leftCuboid.y1 = $cuboidClone.y1
    $leftCuboid.y2 = $cuboidClone.y2
    $leftCuboid.z1 = $cuboidClone.z1
    $leftCuboid.z2 = $cuboidClone.z2
    $leftCuboid.on = $cuboidClone.on
    $cuboidClone.x1 = $overlappingCoordinates["x1"]
    if($leftCuboid.GetVolume() -gt 0){[void]$explodedCubes.Add($leftCuboid)}
    
    ## take everything to the right
    $rightCuboid = [Cuboid]::New()
    $rightCuboid.x1 = $overlappingCoordinates["x2"]
    $rightCuboid.x2 = $cuboidClone.x2
    $rightCuboid.y1 = $cuboidClone.y1
    $rightCuboid.y2 = $cuboidClone.y2
    $rightCuboid.z1 = $cuboidClone.z1
    $rightCuboid.z2 = $cuboidClone.z2
    $rightCuboid.on = $cuboidClone.on
    $cuboidClone.x2 = $overlappingCoordinates["x2"]
    if($rightCuboid.GetVolume() -gt 0){[void]$explodedCubes.Add($rightCuboid)}
    
    ## take everything remaining above
    $topCuboid = [Cuboid]::New()
    $topCuboid.x1 = $cuboidClone.x1
    $topCuboid.x2 = $cuboidClone.x2
    $topCuboid.y1 = $cuboidClone.y1
    $topCuboid.y2 = $cuboidClone.y2
    $topCuboid.z1 = $overlappingCoordinates["z2"]
    $topCuboid.z2 = $cuboidClone.z2
    $topCuboid.on = $cuboidClone.on
    $cuboidClone.z2 = $overlappingCoordinates["z2"]
    if($topCuboid.GetVolume() -gt 0){[void]$explodedCubes.Add($topCuboid)}
    
    ## take everything remaining below
    $bottomCuboid = [Cuboid]::New()
    $bottomCuboid.x1 = $cuboidClone.x1
    $bottomCuboid.x2 = $cuboidClone.x2
    $bottomCuboid.y1 = $cuboidClone.y1
    $bottomCuboid.y2 = $cuboidClone.y2
    $bottomCuboid.z1 = $cuboidClone.z1
    $bottomCuboid.z2 = $overlappingCoordinates["z1"]
    $bottomCuboid.on = $cuboidClone.on
    $cuboidClone.z1 = $overlappingCoordinates["z1"]
    if($bottomCuboid.GetVolume() -gt 0){[void]$explodedCubes.Add($bottomCuboid)}
    
    ## take everything remaining in front
    $frontCuboid = [Cuboid]::New()
    $frontCuboid.x1 = $cuboidClone.x1
    $frontCuboid.x2 = $cuboidClone.x2
    $frontCuboid.y1 = $overlappingCoordinates["y2"]
    $frontCuboid.y2 = $cuboidClone.y2
    $frontCuboid.z1 = $cuboidClone.z1
    $frontCuboid.z2 = $cuboidClone.z2
    $frontCuboid.on = $cuboidClone.on
    $cuboidClone.y2 = $overlappingCoordinates["y2"]
    if($frontCuboid.GetVolume() -gt 0){[void]$explodedCubes.Add($frontCuboid)}
    
    ## take everything remaining behind
    $backCuboid = [Cuboid]::New()
    $backCuboid.x1 = $cuboidClone.x1
    $backCuboid.x2 = $cuboidClone.x2
    $backCuboid.y1 = $cuboidClone.y1
    $backCuboid.y2 = $overlappingCoordinates["y1"]
    $backCuboid.z1 = $cuboidClone.z1
    $backCuboid.z2 = $cuboidClone.z2
    $backCuboid.on = $cuboidClone.on
    $cuboidClone.y1 = $overlappingCoordinates["y1"]
    if($backCuboid.GetVolume() -gt 0){[void]$explodedCubes.Add($backCuboid)}

    return $explodedCubes
}

# Run the jewels
$cuboids = [System.Collections.ArrayList]::new()
foreach($step in $puzzleInput)
{
    $firstSplit = $step.Split(" ")
    $secondSplit = $firstSplit[1].Split(",")
    $newCuboid = [Cuboid]::new()
    $newCuboid.on = if($firstSplit[0] -eq "on"){$true}else{$false}
    $newCuboid.x1, $newCuboid.x2 = $secondSplit[0].Replace("x=","") -split "\.\."
    $newCuboid.y1, $newCuboid.y2 = $secondSplit[1].Replace("y=","") -split "\.\."
    $newCuboid.z1, $newCuboid.z2 = $secondSplit[2].Replace("z=","") -split "\.\."
    $newCuboid.x2++ # remember we're talking about cube locations
    $newCuboid.y2++ # not vertexes of cubes here... so the volume
    $newCuboid.z2++ # needs to be reflective of these additional
                    # cubes... imagine a x=0..1,y=0..1,z=0..1 cube space
                    # it's volume is 1, but technically in this case it
                    # includes 4 cubes (0,0,0..1,1,1)
    $newCuboids = [System.Collections.ArrayList]::new()
    
    foreach($cuboid in $cuboids)
    {
        $overlappingCoordinates = Get-OverlappingCoordinates $cuboid $newCuboid
        if($null -ne $overlappingCoordinates)
        {
            $explodedCubes = Get-ExplodedCuboids $cuboid $overlappingCoordinates
            foreach($explodedCube in $explodedCubes)
            {
                [void]$newCuboids.Add($explodedCube)
            }
        }
        else
        {
            [void]$newCuboids.Add($cuboid)
        }
    }
    [void]$newCuboids.Add($newCuboid)
    $cuboids = $newCuboids
}
[long]($cuboids.Where({$_.on}).GetVolume() | Measure-Object -Sum).Sum
