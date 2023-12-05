#$puzzleInput = Get-Content $PSScriptRoot\example.txt -Raw
$puzzleInput = Get-Content $PSScriptRoot\input.txt -Raw

class NumberMap {
    [Int64]$destination
    [Int64]$source
    [Int64]$sourceMax
    [Int64]$range
    [Int64]$delta
    NumberMap($mapString){
        $this.destination, $this.source, $this.range = $mapString -split "\s+"
        $this.delta = $this.source - $this.destination
        $this.sourceMax = $this.source - 1 + $this.range 
    }
    [bool]TryConvert ([Int64]$number, [ref]$out) {
        if($number -ge $this.source -and $number -lt ($this.source+$this.range)){
            $out.Value = ($number - $this.delta)
            return $true
        }
        return $false
    }
}

class SeedRange {
    # So for every "round" you will split the existing ranges into a new set of ranges
    # that match the available maps... then perform the function against start and end
    # to have your new ranges to test...
    [Int64]$start
    [Int64]$end
    SeedRange($s,$e){$this.start = $s; $this.end = [Int64]$e}
}

$seeds, $maps = $puzzleInput -split "\r\n\r\n"
$null, $seeds = $seeds -split "\s+"

$seedRanges = [System.Collections.Generic.List[object]]::new()
for($i = 0; $i -lt $seeds.Count; $i+=2)
{
    $seedRanges.Add([SeedRange]::new($seeds[$i], ([Int64]$seeds[$i] + $seeds[($i+1)] - 1)))
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
    $mapArray = [System.Collections.Generic.List[object]]::new(($mapArray | Sort-Object -Property source))
    if($mapArray[0].source -ne 0){$mapArray.Add([NumberMap]::new("0 0 $($mapArray[0].source)"))}

    $newMapArray = [System.Collections.Generic.List[object]]::new(($mapArray | Sort-Object -Property source))
    for($i = 0; $i -lt $newMapArray.Count; $i++)
    {
        if($i -eq ($newMapArray.Count - 1) -or $newMapArray[$i].sourceMax -eq ($newMapArray[($i+1)].source - 1)){continue}
        $mapArray.Add([NumberMap]::new("$($newMapArray[$i].sourceMax + 1) $($newMapArray[$i].sourceMax + 1) $($newMapArray[($i+1)].source - $newMapArray[$i].sourceMax -1)"))
    }
    $mapArray = [System.Collections.Generic.List[object]]::new(($mapArray | Sort-Object -Property source))
    $mapArray.Add([NumberMap]::new("$($mapArray[-1].sourceMax + 1) $($mapArray[-1].sourceMax + 1) $([Int64]::MaxValue - $mapArray[-1].sourceMax)"))
    $mapList.Add($mapArray)
}

foreach($mapGroup in $mapList.GetEnumerator())
{
    $newSeedRanges = [System.Collections.Generic.List[object]]::new()
    foreach($seedRange in $seedRanges)
    {
        $startMap = $mapGroup.Where({$seedRange.start -ge $_.source -and $seedRange.start -le $_.sourceMax})[0]
        $startIndex = $mapGroup.IndexOf($startMap)
        $endMap = $mapGroup.Where({$seedRange.end -ge $_.source -and $seedRange.end -le $_.sourceMax})[0]
        $endIndex = $mapGroup.IndexOf($endMap)

        if($startIndex -eq $endIndex)
        {
            $ns = 0
            $ne = 0
            [void]$startMap.TryConvert($seedRange.start, [ref]$ns)
            [void]$startMap.TryConvert($seedRange.end, [ref]$ne)
            $newSeedRanges.Add([SeedRange]::new($ns, $ne))
        }
        else
        {
            for($i = $startIndex; $i -le $endIndex; $i++)
            {
                if($i -eq $startIndex){
                    $ns = 0
                    $ne = 0
                    [void]$mapGroup[$i].TryConvert($seedRange.start, [ref]$ns)
                    [void]$mapGroup[$i].TryConvert($mapGroup[$i].sourceMax, [ref]$ne)
                    $newSeedRanges.Add([SeedRange]::new($ns, $ne))
                }
                elseif($i -eq $endIndex){
                    $ns = 0
                    $ne = 0
                    [void]$mapGroup[$i].TryConvert(($mapGroup[($i-1)].sourceMax + 1), [ref]$ns)
                    [void]$mapGroup[$i].TryConvert($seedRange.end, [ref]$ne)
                    $newSeedRanges.Add([SeedRange]::new($ns, $ne))
                }
                else{
                    $ns = 0
                    $ne = 0
                    [void]$mapGroup[$i].TryConvert(($mapGroup[($i-1)].sourceMax + 1), [ref]$ns)
                    [void]$mapGroup[$i].TryConvert($mapGroup[$i].sourceMax, [ref]$ne)
                    $newSeedRanges.Add([SeedRange]::new($ns, $ne))
                }
            }
        }  
    }
    $seedRanges = $newSeedRanges
}
($seedRanges.start | Sort-Object)[0]