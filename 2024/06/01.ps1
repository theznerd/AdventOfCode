#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

class Guard {
    [int]$positionX = 0
    [int]$positionY = 0
    $direction = "up"
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
        $puzzleHash["$x,$y"] = $puzzleInput[$y][$x]
        switch ($puzzleInput[$y][$x]){
            '^' {$Guard.positionX = $x; $Guard.positionY = $y; $Guard.direction = "up"}
            '>' {$Guard.positionX = $x; $Guard.positionY = $y; $Guard.direction = "right"}
            '<' {$Guard.positionX = $x; $Guard.positionY = $y; $Guard.direction = "left"}
            'v' {$Guard.positionX = $x; $Guard.positionY = $y; $Guard.direction = "down"}
        }
    }
}

While($Guard.positionY -ge $mapTop -and 
      $Guard.positionY -le $mapBottom -and
      $Guard.positionX -ge $mapLeft -and
      $Guard.positionX -le $mapRight)
{
    # Poop an X
    $puzzleHash["$($Guard.positionX),$($Guard.PositionY)"] = "X"

    # Check next space
    $blocked = $false
    switch ($Guard.direction){
        "up"    {if($puzzleHash["$($Guard.positionX),$($Guard.PositionY-1)"] -eq "#"){$Guard.direction = "right"; $blocked = $true}}
        "right" {if($puzzleHash["$($Guard.positionX+1),$($Guard.PositionY)"] -eq "#"){$Guard.direction = "down"; $blocked = $true}}
        "left"  {if($puzzleHash["$($Guard.positionX-1),$($Guard.PositionY)"] -eq "#"){$Guard.direction = "up"; $blocked = $true}}
        "down"  {if($puzzleHash["$($Guard.positionX),$($Guard.PositionY+1)"] -eq "#"){$Guard.direction = "left"; $blocked = $true}}
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
$puzzleHash.Values.Where({$_ -eq "X"}).Count