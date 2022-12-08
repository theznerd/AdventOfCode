$input = Get-Content $PSScriptRoot\example.txt

class ElfTree {
    [int]$x
    [int]$y
    [int]$height
    ELfTree($x, $y, $height)
    {
        $this.x = $x
        $this.y = $y
        $this.height = $height
    }
    [bool]IsVisible($treeMap)
    {
        $maxX = [System.Linq.Enumerable]::Max([int[]]$treeMap.x)
        $maxY = [System.Linq.Enumerable]::Max([int[]]$treeMap.y)
        if($this.x -eq 0 -or $this.x -eq $maxX){return $true}
        elseif($this.y -eq 0 -or $this.y -eq $maxY){return $true}

        $maxUp = [System.Linq.Enumerable]::Max([int[]]($treeMap.Where({$_.y -ge 0 -and $_.y -lt $this.y -and $_.x -eq $this.x}).height))
        $maxDown = [System.Linq.Enumerable]::Max([int[]]($treeMap.Where({$_.y -gt $this.y -and $_.y -le $maxY -and $_.x -eq $this.x}).height))
        $maxLeft = [System.Linq.Enumerable]::Max([int[]]($treeMap.Where({$_.x -ge 0 -and $_.x -lt $this.x -and $_.y -eq $this.y}).height))
        $maxRight = [System.Linq.Enumerable]::Max([int[]]($treeMap.Where({$_.x -gt $this.x -and $_.x -le $maxX -and $_.y -eq $this.y}).height))
        if(
            $this.height -gt $maxLeft -or
            $this.height -gt $maxRight -or
            $this.height -gt $maxUp -or
            $this.height -gt $maxDown
        ){return $true}
        else{return $false}
    }
}

$treeMap = [System.Collections.Generic.List[ElfTree]]@()
$y = 0
foreach($r in $input)
{
    for($x = 0; $x -lt $r.Length; $x++)
    {
        [void]$treeMap.Add([ElfTree]::new($x,$y,"$($r[$x])"))
    }
    $y++
}

$treeMap.Where({$_.IsVisible($treeMap) -eq $true}).Count