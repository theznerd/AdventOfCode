## The input here is too large for brute force via recursion...
## Crap.

#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

# Trying something new for the grid
$rows = $puzzleInput.Count
$columns = $puzzleInput[0].Length
[char[,]]$splitterMap = [char[,]]::new($columns, $rows)

for($y = 0; $y -lt $rows; $y++){
    for($x = 0; $x -lt $columns; $x++){
        $splitterMap[$x, $y] = $puzzleInput[$y][$x]
        if($puzzleInput[$y][$x] -eq "S"){
            $startingX, $startingY = @($x, $y) 
        }
    }
}

# recursively find all the paths from the start to the end
# trace the path until we reach a splitter
# when we reach a splitter we invoke the recursive function from the current position +1 and -1 X
# if we reach the bottom, we return 1

function Get-PathsFromPosition {
    param(
        [int]$startingX,
        [int]$startingY
    )
    $currentX = $startingX
    $currentY = $startingY
    $pathCount = 0

    while($true){
        $currentY += 2
        if($splitterMap[$currentX,$currentY] -eq "^"){ # Have Encountered a splitter
            $pathCount += Get-PathsFromPosition -startingX ($currentX - 1) -startingY $currentY
            $pathCount += Get-PathsFromPosition -startingX ($currentX + 1) -startingY $currentY
            break # We do not continue after encountering a splitter
        }
        elseif($currentY -eq $rows){ # Have reached bottom
            return $pathCount + 1
        }
    }
    return $pathCount
}

Get-PathsFromPosition -startingX $startingX -startingY $startingY