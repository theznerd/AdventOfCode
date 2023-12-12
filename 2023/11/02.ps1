#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

class Galaxy {
    [long]$ox
    [long]$oy
    [long]$x
    [long]$y
    [long]$totalDistances
    [System.Collections.Generic.List[long]]$distances = [System.Collections.Generic.List[long]]::new()
    Galaxy($x,$y)
    {
        $this.ox = $x
        $this.oy = $y
        $this.x = $x
        $this.y = $y
    }

    [int]GetDistance([Galaxy]$g)
    {
        return [Math]::Abs($g.x - $this.x) + [Math]::Abs($g.y - $this.y)
    }
}

$expansionFactor = 1000000 - 1

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
$expandRows = [System.Linq.Enumerable]::ToList([System.Linq.Enumerable]::Except($rowMask,$galaxyRows))

foreach($g in $galaxies)
{
    if(($expandCols.Where({$_ -lt $g.ox}).Count) -gt 0){
        $g.x += ($expandCols.Where({$_ -lt $g.ox}).Count)*$expansionFactor
    }
    if(($expandRows.Where({$_ -lt $g.oy}).Count) -gt 0){
        $g.y += ($expandRows.Where({$_ -lt $g.oy}).Count)*$expansionFactor
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