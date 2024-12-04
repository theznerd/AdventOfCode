#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

# Map Puzzle
$puzzleHash = @{}
for($y = 0; $y -lt $puzzleInput.Count; $y++){
    for($x = 0; $x -lt $puzzleInput[0].Length; $x++){
        $puzzleHash["$x,$y"] = $puzzleInput[$y][$x]
    }
}

# Valid Directions
$directions = @(
    @{x =  1; y =  0 },
    @{x = -1; y =  0 },
    @{x =  0; y = -1 },
    @{x =  0; y =  1 },
    @{x =  1; y = -1 },
    @{x = -1; y = -1 },
    @{x =  1; y =  1 },
    @{x = -1; y =  1 }
)

$xmas = 0
foreach($letterX in $puzzleHash.GetEnumerator().Where({$_.Value -eq "X"})){
    #Brute Force Test Directions
    foreach($direction in $directions){
        [int]$x,[int]$y = $letterX.Name.Split(",")
        if(
            $puzzleHash["$($x+$direction.x*1),$($y+$direction.y*1)"] -eq "M" -and
            $puzzleHash["$($x+$direction.x*2),$($y+$direction.y*2)"] -eq "A" -and
            $puzzleHash["$($x+$direction.x*3),$($y+$direction.y*3)"] -eq "S"
        ){
            $xmas++
        }
    }
}
$xmas