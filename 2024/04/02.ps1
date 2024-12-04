#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

# Map Puzzle
$puzzleHash = @{}
for($y = 0; $y -lt $puzzleInput.Count; $y++){
    for($x = 0; $x -lt $puzzleInput[0].Length; $x++){
        $puzzleHash["$x,$y"] = $puzzleInput[$y][$x]
    }
}

$msPositions = @(
    @{x1 =  1; y1 = -1; x2 = -1; y2 = 1 },
    @{x1 = -1; y1 = -1; x2 = 1; y2 = 1 }
)

$xmas = 0
:nextA foreach($letterX in $puzzleHash.GetEnumerator().Where({$_.Value -eq "A"})){
    #Brute Force Test Positions
    [int]$x,[int]$y = $letterX.Name.Split(",")
    foreach($position in $msPositions){
        $msValues = @($puzzleHash["$($x+$position.x1),$($y+$position.y1)"],$puzzleHash["$($x+$position.x2),$($y+$position.y2)"])
        if(!("M" -in $msValues -and "S" -in $msValues)){
            continue nextA
        }
    }
    $xmas++
}
$xmas