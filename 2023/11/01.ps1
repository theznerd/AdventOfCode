#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

class Galaxy {
    [int]$x
    [int]$y
    [int]$totalDistances
    [System.Collections.Generic.List[int]]$distances = [System.Collections.Generic.List[int]]::new()
    Galaxy($x,$y)
    {
        $this.x = $x
        $this.y = $y
    }

    [int]GetDistance([Galaxy]$g)
    {
        return [Math]::Abs($g.x - $this.x) + [Math]::Abs($g.y - $this.y)
    }
}

$galaxies = [System.Collections.Generic.List[Galaxy]]::new()
for($y = 0; $y -lt $puzzleInput.Count; $y++)
{
    for($x = 0; $x -lt $puzzleInput[0].Length; $x++)
    {
        if($puzzleInput[$y][$x] -eq "#"){$galaxies.Add([Galaxy]::new($x,$y))}
    }
}

[System.Collections.Generic.List[int]]$galaxyColumns = ($galaxies.x | Select-Object -Unique)
[System.Collections.Generic.List[int]]$galaxyRows = ($galaxies.y | Select-Object -Unique)
[System.Collections.Generic.List[int]]$columnMask = 0..($puzzleInput[0].Length - 1)
[System.Collections.Generic.List[int]]$rowMask = 0..($puzzleInput.Count - 1)
$expandCols = [System.Linq.Enumerable]::ToList([System.Linq.Enumerable]::Except($columnMask,$galaxyColumns))
$expandColCount = $expandCols.Count
$expandRows = [System.Linq.Enumerable]::ToList([System.Linq.Enumerable]::Except($rowMask,$galaxyRows))
$expandRowCount = $expandRows.Count

$expandedMap = ""
for($y = 0; $y -lt $rowMask.Count; $y++)
{
    [string]$row = $puzzleInput[$y]
    for($i = 0; $i -lt $expandColCount; $i++)
    {
        $row = $row.Insert(($i + $expandCols[$i]),".")
    }
    $expandedMap += "$row`r`n"
    if($y -in $expandRows){$expandedMap += "."*($rowMask.Count + $expandRowCount); $expandedMap += "`r`n"}
}
$expandedMap = $expandedMap -split "`r`n"

## redraw galaxies
$galaxies = [System.Collections.Generic.List[Galaxy]]::new()
for($y = 0; $y -lt $expandedMap.Count; $y++)
{
    for($x = 0; $x -lt $expandedMap[0].Length; $x++)
    {
        if($expandedMap[$y][$x] -eq "#"){$galaxies.Add([Galaxy]::new($x,$y))}
    }
}

foreach($g in $galaxies)
{
    foreach($tg in $galaxies)
    {
        $d = $g.GetDistance($tg)
        $g.distances.Add($d)
        $g.totalDistances += $d
    }
}
(($galaxies.totalDistances | Measure-Object -Sum).Sum / 2)