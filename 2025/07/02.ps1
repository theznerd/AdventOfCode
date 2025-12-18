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

# Memoization time...
$memoizationTable = @{}
function Get-PathsFromPosition {
    param(
        [int]$startingX,
        [int]$startingY
    )

    if($null -ne $memoizationTable["$startingX,$startingY"]){
        return $memoizationTable["$startingX,$startingY"]
    }

    $children = (Get-ChildrenFromPosition -startingX $startingX -startingY $startingY)

    if($children.count -eq 0){
        $memoizationTable["$startingX,$startingY"] = 1
        return 1
    }

    $totalPaths = 0
    foreach($child in $children){
        $totalPaths += Get-PathsFromPosition -startingX $child.x -startingY $child.y
    }

    $memoizationTable["$startingX,$startingY"] = $totalPaths
    return $totalPaths
}

class Child {
    [int]$x
    [int]$y
    Child($x,$y){
        $this.x = $x
        $this.y = $y
    }
}

function Get-ChildrenFromPosition {
    param(
        [int]$startingX,
        [int]$startingY
    )
    $children = [Collections.Generic.List[Child]]::new()
    if($splitterMap[$startingX,$startingY] -eq "^"){
        $leftChildX = $startingX-1
        $leftChildY = $startingY
        while($true){
            $leftChildY +=2
            if($splitterMap[$leftChildX,$leftChildY] -eq "^" -or $leftChildY -eq $rows)
            {
                $children.Add([Child]::new($leftChildX,$leftChildY))
                break
            }elseif($leftChildY -gt $rows){break}
        }

        $rightChildX = $startingX+1
        $rightChildY = $startingY
        while($true){
            $rightChildY +=2
            if($splitterMap[$rightChildX,$rightChildY] -eq "^" -or $rightChildY -eq $rows)
            {
                $children.Add([Child]::new($rightChildX,$rightChildY))
                break
            }elseif($rightChildY -gt $rows){break}
        }
        return $children
    }else{
        # check straight down from here
        while($true){
            $startingY += 2
            if($splitterMap[$startingX,$startingY] -eq "^" -or $startingY -eq $rows)
            {
                $children.Add([Child]::new($startingX,$startingY))
                return $children
            }elseif($startingY -gt $rows){return $children}
        }
    }
}

Get-PathsFromPosition -startingX $startingX -startingY $startingY