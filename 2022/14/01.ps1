$puzzleInput = Get-Content $PSScriptRoot\input.txt
$puzzleInput = $puzzleInput | select -Unique


$coordsRegEx = [Regex]::new('(\d*),(\d*)')
$coords = $coordsRegEx.Matches($puzzleInput)
$minX = [int]::MaxValue
$maxX = 500 #maxX must at least be 500, because sand falls from 500,0
$minY = 0 #minY is always zero, since sand falls from 500,0
$maxY = 0
foreach($c in $coords.value)
{
    [int]$x, [int]$y = $c -split ","
    if($x -lt $minX){$minX = $x}
    if($x -gt $maxX){$maxX = $x}
    if($y -gt $maxY){$maxY = $y}
}
$maxX++
$maxY++

$xAdj = 0 - $minX
$sandStartX = 500 + $xAdj
$sandStartY = 0

$map = New-Object "string[,]" ($maxX - $minX), ($maxY - $minY)

foreach($line in $puzzleInput)
{
    $coords = $line.Split(" -> ")
    for($i = 0; $i -lt ($coords.count - 1); $i++)
    {
        [int]$coordOneX, [int]$coordOneY = $coords[$i].Split(",")
        [int]$coordTwoX, [int]$coordTwoY = $coords[($i+1)].Split(",")

        $coordOneX = $coordOneX + $xAdj
        $coordTwoX = $coordTwoX + $xAdj

        $ySpread = $coordOneY .. $coordTwoY
        $xSpread = $coordOneX .. $coordTwoX
        foreach($y in $ySpread)
        {
            foreach($x in $xSpread)
            {
                $map[$x,$y] = "#"
            }
        }
    }
}

class Sand
{
    static [System.Array] NewSand([string[,]]$m,$s)
    {
        $inMotion = $true
        [int]$xPos, [int]$yPos = $s -split ","
        while($inMotion)
        {
            if($yPos+1 -gt $m.GetLength(1))
            {
                return @(-1); # we're outside the bounds of the map
            }
            if([String]::IsNullOrWhiteSpace(($m[$xpos,($ypos+1)])))
            {
                $yPos++
                continue
            }
            elseif($xPos-1 -lt 0)
            {
                return @(-1); # we're outside the bounds of the map
            }
            elseif([String]::IsNullOrWhiteSpace(($m[($xpos-1),($ypos+1)])))
            {
                $xPos--
                $yPos++
                continue
            }
            elseif($xPos+1 -gt $m.GetLength(0))
            {
                return @(-1); # we're outside the bounds of the map
            }
            elseif([String]::IsNullOrWhiteSpace(($m[($xpos+1),($ypos+1)])))
            {
                $xPos++
                $yPos++
                continue
            }
            else
            {
                $inMotion = $false
                continue
            }
        }
        return @($xPos, $yPos)
    }
}

function New-Map($m)
{
    for($y = 0; $y -lt $m.GetLength(1); $y++)
    {
        $mapLine = ""
        for($x = 0; $x -lt $m.GetLength(0); $x++)
        {
            switch($m[$x,$y])
            {
                "#" {$mapLine += "#"; break}
                "o" {$mapLine += "o"; break}
                default {$mapLine += "."}
            }
        }
        Write-Output $mapLine
    }
}

do {
    $output = [Sand]::NewSand($map,"$sandStartX,$sandStartY")
    if($output[0] -ne -1)
    {
        $map[$output[0],$output[1]] = "o"
    }
}until($output[0] -eq -1)

$map.Where({$_ -eq "o"}).Count