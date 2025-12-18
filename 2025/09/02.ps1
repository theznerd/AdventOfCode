#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

$points = [Collections.Generic.List[object]]::new()
foreach($line in $puzzleInput){
    $x, $y = $line -split ","
    $point = [PSCustomObject]@{
        x = [int]$x
        y = [int]$y
    }
    $points.Add($point)
}

# Create the bounding geometry that the max area must fit within
Add-Type -AssemblyName PresentationCore ## lots of drawing items in here
$tileBoundary = [System.Windows.Media.PathGeometry]::new()
$tileFigure = [System.Windows.Media.PathFigure]::new()
$tileFigure.IsClosed = $true
$tileFigure.IsFilled = $true
$tileFigure.StartPoint = "$($points[0].x),$($points[0].y)"
$tileSegments = [System.Windows.Media.PathSegmentCollection]::new()
for($i = 1; $i -lt $points.Count; $i++){
    $lineSegment = [System.Windows.Media.LineSegment]::new()
    $lineSegment.Point = "$($points[$i].x),$($points[$i].y)"
    $tileSegments.Add($lineSegment)
}
$lineSegment = [System.Windows.Media.LineSegment]::new()
    $lineSegment.Point = "$($points[0].x),$($points[0].y)"
    $tileSegments.Add($lineSegment)
$tileFigure.Segments = $tileSegments
$tileBoundary.Figures.Add($tileFigure)

# Calculate area for each pair of points... yuck...
$rectanglesToTest = [Collections.Generic.List[object]]::new()
for($i = 0; $i -lt $points.Count - 1; $i++){
    for($j = $i + 1; $j -lt $points.Count; $j++){
        $pointA = $points[$i]
        $pointB = $points[$j]
        $area = ([Math]::Abs($pointA.x - $pointB.x) + 1) * ([Math]::Abs($pointA.y - $pointB.y) + 1)
        $rectanglesToTest.Add(@{
            pointA = $pointA
            pointB = $pointB
            area = $area
        })
    }
}

# Now that we have all rectangles, test each one to see if it fits within the tile boundary
# Sort rectangles by area descending so we can short-circuit on the first that fits
$rectanglesToTest = $rectanglesToTest | Sort-Object area -Descending

foreach($rectangle in $rectanglesToTest){
    # Cheat and make the rectangle slightly smaller
    # FillContains does not consider touching edges to be "contained within"
    # As long as we reduce each side by probably <1 units it shouldn't add
    # any false positives? We'll make it 0.5 units for safety
    $xMin = [Math]::Min($rectangle.pointA.x, $rectangle.pointB.x)
    $xMax = [Math]::Max($rectangle.pointA.x, $rectangle.pointB.x)
    $yMin = [Math]::Min($rectangle.pointA.y, $rectangle.pointB.y)
    $yMax = [Math]::Max($rectangle.pointA.y, $rectangle.pointB.y)
    $pointA = [PSCustomObject]@{
        x = $xMin + 0.5
        y = $yMin + 0.5
    }
    $pointB = [PSCustomObject]@{
        x = $xMax - 0.5
        y = $yMax - 0.5
    }

    $rectGeometry = [System.Windows.Media.PathGeometry]::new()
    $rectFigure = [System.Windows.Media.PathFigure]::new()
    $rectFigure.IsClosed = $true
    $rectFigure.IsFilled = $true
    $rectFigure.StartPoint = "$($pointA.x),$($pointA.y)"

    $rectSegments = [System.Windows.Media.PathSegmentCollection]::new()
    $lineSegment1 = [System.Windows.Media.LineSegment]::new()
    $lineSegment1.Point = "$($pointB.x),$($pointA.y)"
    $lineSegment2 = [System.Windows.Media.LineSegment]::new()
    $lineSegment2.Point = "$($pointB.x),$($pointB.y)"
    $lineSegment3 = [System.Windows.Media.LineSegment]::new()
    $lineSegment3.Point = "$($pointA.x),$($pointB.y)"
    $lineSegment4 = [System.Windows.Media.LineSegment]::new()
    $lineSegment4.Point = "$($pointA.x),$($pointA.y)"

    $rectSegments.Add($lineSegment1)
    $rectSegments.Add($lineSegment2)
    $rectSegments.Add($lineSegment3)
    $rectSegments.Add($lineSegment4)
    $rectFigure.Segments = $rectSegments
    $rectGeometry.Figures.Add($rectFigure)

    # Test if the rectangle is fully contained within the tile boundary
    if($tileBoundary.FillContains($rectGeometry)){
        # This is the largest area that fits
        $rectangle.area
        break
    }
}