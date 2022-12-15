$puzzleInput = Get-Content $PSScriptRoot\input.txt

## time to cheat!
Add-Type -AssemblyName PresentationCore ## lots of drawing items in here

class Sensor {
    [int]$x
    [int]$y
    [Beacon]$closestBeacon
    [System.Windows.Media.PathGeometry]$geometry
    Sensor($x,$y,$beacon)
    {
        $this.x = $x
        $this.y = $y
        $this.closestBeacon = $beacon

        ## generate the geometry
        $travel = $this.GetDistanceToBeacon()
        $pathFigure = [System.Windows.Media.PathFIgure]::new()
        $pathFigure.IsClosed = $true
        $pathFigure.IsFilled = $true
        $pathFigure.StartPoint = "$($this.x - $travel),$($this.y)"  #west
        
        $pathSegmentCollection = [System.Windows.Media.PathSegmentCollection]::new()
        $pathSegmentOne = [System.Windows.Media.LineSegment]::new()
        $pathSegmentOne.Point = "$($this.x),$($this.y - $travel)" #north
        $pathSegmentTwo = [System.Windows.Media.LineSegment]::new()
        $pathSegmentTwo.Point = "$($this.x + $travel),$($this.y)" #east
        $pathSegmentThree = [System.Windows.Media.LineSegment]::new()
        $pathSegmentThree.Point = "$($this.x),$($this.y + $travel)" #south

        $pathSegmentCollection.Add($pathSegmentOne)
        $pathSegmentCollection.Add($pathSegmentTwo)
        $pathSegmentCollection.Add($pathSegmentThree)

        $pathFigure.Segments = $pathSegmentCollection

        $this.geometry = [System.Windows.Media.PathGeometry]::new()
        $this.geometry.Figures.Add($pathFigure)
        $this.geometry.FillRule = [System.Windows.Media.FillRule]::Nonzero
    }

    hidden [int] GetDistanceToBeacon()
    {
        $xDistance = [Math]::Abs($this.x - $this.closestBeacon.x)
        $yDistance = [Math]::Abs($this.y - $this.closestBeacon.y)
        return $xDistance + $yDistance
    }
}

class Beacon {
    [int]$x
    [int]$y
    Beacon($x,$y)
    {
        $this.x = $x
        $this.y = $y
    }
}

$sensors = [System.Collections.Generic.List[Sensor]]@()
$beacons = [System.Collections.Generic.List[Beacon]]@()

$regX = [regex]::new('(x=(-?\d*))')
$regY = [regex]::new('(y=(-?\d*))')
foreach($i in $puzzleInput)
{
    $sensorText, $beaconText = $i -split ": "

    [int]$sensorX = $regX.Matches($sensorText).Groups[2].Value
    [int]$sensorY = $regY.Matches($sensorText).Groups[2].Value
    [int]$beaconX = $regX.Matches($beaconText).Groups[2].Value
    [int]$beaconY = $regY.Matches($beaconText).Groups[2].Value

    $beacon = [Beacon]::new($beaconX,$beaconY)
    [void]$beacons.Add($beacon)
    [void]$sensors.Add([Sensor]::new($sensorX,$sensorY,$beacon))
}

$Bound = 4000000
$MaskPathGeo = [System.Windows.Media.PathGeometry]::new()
$pathFigure = [System.Windows.Media.PathFigure]::new()
$pathFigure.IsClosed = $true
$pathFigure.IsFilled = $true
$pathFigure.StartPoint = "0,0"  #top left
$pathSegmentCollection = [System.Windows.Media.PathSegmentCollection]::new()
$pathSegmentOne = [System.Windows.Media.LineSegment]::new()
$pathSegmentOne.Point = "$Bound,0" #top right
$pathSegmentTwo = [System.Windows.Media.LineSegment]::new()
$pathSegmentTwo.Point = "$Bound,$Bound" #bottom right
$pathSegmentThree = [System.Windows.Media.LineSegment]::new()
$pathSegmentThree.Point = "0,$Bound" #bottom let
$pathSegmentCollection.Add($pathSegmentOne)
$pathSegmentCollection.Add($pathSegmentTwo)
$pathSegmentCollection.Add($pathSegmentThree)
$pathFigure.Segments = $pathSegmentCollection
$MaskPathGeo.Figures.Add($pathFigure)
$MaskPathGeo.FillRule = [System.Windows.Media.FillRule]::Nonzero


$MasterPathGeo = [System.Windows.Media.PathGeometry]::new()
$MasterPathGeo.FillRule = [System.Windows.Media.FillRule]::Nonzero

foreach($sensor in $sensors)
{
    [void]$MasterPathGeo.AddGeometry($sensor.geometry)
}

$regPoint = [regex]::new('M(.*?)L')
$ExcludeGeo = [System.Windows.Media.Geometry]::Combine($MaskPathGeo, $MasterPathGeo,[System.Windows.Media.GeometryCombineMode]::Exclude, $null)
$ExcludePath = $ExcludeGeo.Figures.ToString()
$ExcludePoints = $regPoint.Matches($ExcludePath).Groups.Where({$_.Name -eq 1}).Value

## This is straight horseshoes and handgrendaes
## It only put out three answers though...
## So I went ahead and tested them in order
foreach($p in $ExcludePoints)
{
    [int]$x,[int]$y = $p -Split ","
    $y++
    Write-Output "Potential: $x,$y"
    $pv = ($x * 4000000) + $y
    Write-Output "Potential Value: $pv"
    Write-Output ""
}