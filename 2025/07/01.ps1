#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

# Trying something new for the grid
$rows = $puzzleInput.Count
$columns = $puzzleInput[0].Length
[char[,]]$splitterMap = [char[,]]::new($columns, $rows)

$beamSplits = 0
for($y = 0; $y -lt $rows; $y++){
    for($x = 0; $x -lt $columns; $x++){
        # may as well just solve while we populate the grid
        # n conditions
        # 1. nothing above - populate input
        # 2. S above - becomes pipe
        # 3. . with | above - x,y of . become |
        # 4. ^ with | above - left and right of ^ become | (note, all ^ have at least one space between them - there is no ^^)
        #    INCREMENT BEAM SPLIT COUNTER
        # 5. Else put character
        if($y - 1 -eq -1)
        {
            $splitterMap[$x,$y] = $puzzleInput[$y][$x]
        }
        elseif($puzzleInput[$y-1][$x] -eq "S")
        {
            $splitterMap[$x,$y] = "|"
        }
        elseif($puzzleInput[$y][$x] -eq "." -and $splitterMap[$x,($y-1)] -eq "|")
        {
            $splitterMap[$x,$y] = "|"
        }
        elseif($puzzleInput[$y][$x] -eq "^" -and $splitterMap[$x,($y-1)] -eq "|")
        {
            $splitterMap[$x,$y] = "^"
            $splitterMap[($x-1),$y] = "|"
            $splitterMap[($x+1),$y] = "|"
            $x++ # skip the next column since we already set it's value
            $beamSplits++
        }
        else
        {
            $splitterMap[$x,$y] = $puzzleInput[$y][$x]
        }
    }
}
$beamSplits

<# Mapping
for($y = 0; $y -lt $rows; $y++)
{
    $mapLine = ""
    for($x = 0; $x -lt $columns; $x++)
    {
        $mapLine += $splitterMap[$x,$y]
    }
    Write-Output $mapLine
}
#>