#$puzzleInput = Get-Content $PSScriptRoot\example.txt -Raw
$puzzleInput = Get-Content $PSScriptRoot\input.txt -Raw

class NumberMap {
    [Int64]$destination
    [Int64]$source
    [Int64]$range
    [Int64]$delta
    NumberMap($mapString){
        $this.destination, $this.source, $this.range = $mapString -split "\s+"
        $this.delta = $this.source - $this.destination
    }
    [bool]TryConvert ([Int64]$number, [ref]$out) {
        if($number -ge $this.source -and $number -lt ($this.source+$this.range)){
            $out.Value = ($number - $this.delta)
            return $true
        }else{
            return $false
        }
    }
}

$seeds, $maps = $puzzleInput -split "\r\n\r\n"
$null, $seeds = $seeds -split "\s+"
$seedList = @{}
foreach($seed in $seeds){
    $seedList.Add("$seed", $seed)
}

$mapList = [System.Collections.Generic.List[object]]::new()
foreach($map in $maps)
{
    $mapArray = [System.Collections.Generic.List[object]]::new()
    $null, $mapNumbers = $map -split "\r\n"
    foreach($mn in $mapNumbers)
    {
        $mapArray.Add([NumberMap]::new($mn))
    }
    $mapList.Add($mapArray)
}


foreach($mapGroup in $mapList.GetEnumerator())
{
    :seed foreach($seed in $seeds)
    {
        foreach($map in $mapGroup.GetEnumerator())
        {
            $v = [Int64]::MinValue
            if($map.TryConvert($seedList[$seed], [ref]$v))
            {
                $seedList[$seed] = $v; continue seed
            }
        }    
    }
}
($seedList.Values | Sort-Object)[0]