#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

class JunctionBox {
    [int]$x
    [int]$y
    [int]$z
    [bool]$inCircuitBox = $false
    JunctionBox($x,$y,$z){
        $this.x = $x
        $this.y = $y
        $this.z = $z
    }
    ##[hashtable]$distancesToOtherPoints = @{}
    [double]DistanceBetween($other){
        return [Math]::Sqrt([Math]::Pow($this.x - $other.x,2) + [Math]::Pow($this.y - $other.y,2) + [Math]::Pow($this.z - $other.z,2))
    }
}

class Distance : IComparable {
    [JunctionBox]$junctionBoxOne
    [JunctionBox]$junctionBoxTwo
    [double]$Distance
    Distance($jb1, $jb2, $distance)
    {
        $this.junctionBoxOne = $jb1
        $this.junctionBoxTwo = $jb2
        $this.distance = $distance
    }
    [int]CompareTo($other) {
        if ($this.Distance -lt $other.Distance) { return -1 }
        if ($this.Distance -gt $other.Distance) { return 1 }
        return 0
    }
}

class Circuit {
    [Collections.Generic.List[JunctionBox]]$junctionBoxes = [Collections.Generic.List[JunctionBox]]::new()
    [void]AddJunctionBox($junctionBox){
        $this.junctionBoxes.Add($junctionBox)
        $junctionBox.inCircuitBox = $true
    }
}

# Map distances between all junction boxes
$junctionBoxes = [Collections.Generic.List[JunctionBox]]::new()
$distances = [Collections.Generic.List[Distance]]::new()
foreach($coordinate in $puzzleInput)
{
    $x, $y, $z = $coordinate -split ","
    $junctionBox = [JunctionBox]::new($x, $y, $z)
    foreach($otherJunctionBox in $junctionBoxes){
        $distances.Add([Distance]::new($junctionBox, $otherJunctionBox, $junctionBox.DistanceBetween($otherJunctionBox)))
    }
    $junctionBoxes.Add($junctionBox)
}
$distances.Sort()

$circuits = [Collections.Generic.List[Circuit]]::new()
for($i = 0; $i -lt 1000; $i++)
{
    Write-Output "Going the distance for $i of 1000"
    $junctionBox1, $junctionBox2 = $distances[$i].junctionBoxOne, $distances[$i].junctionBoxTwo
    if($junctionBox1 -notin $circuits.junctionBoxes -and $junctionBox2 -notin $circuits.junctionBoxes){
        # Neither junction box is in a circuit yet - create a new circuit
        $circuit = [Circuit]::new()
        $circuit.AddJunctionBox($junctionBox1)
        $circuit.AddJunctionBox($junctionBox2)
        $circuits.Add($circuit)
    }
    if($junctionBox1.inCircuitBox -and -not $junctionBox2.inCircuitBox){
        # Junction box 1 is in a circuit, add junction box 2 to it
        $circuits.Where({$_.junctionBoxes -contains $junctionBox1})[0].AddJunctionBox($junctionBox2)
    }
    elseif($junctionBox2.inCircuitBox -and -not $junctionBox1.inCircuitBox){
        # Junction box 2 is in a circuit, add junction box 1 to it
        $circuits.Where({$_.junctionBoxes -contains $junctionBox2})[0].AddJunctionBox($junctionBox1)
    }elseif($junctionBox1.inCircuitBox -and $junctionBox2.inCircuitBox){
        # Both junction boxes are already in circuits - we need to merge them...
        $circuit1 = $circuits.Where({$_.junctionBoxes -contains $junctionBox1})[0]
        $circuit2 = $circuits.Where({$_.junctionBoxes -contains $junctionBox2})[0]
        if($circuit1 -ne $circuit2){
            foreach($jb in $circuit2.junctionBoxes){
                $circuit1.AddJunctionBox($jb)
            }
            [void]$circuits.Remove($circuit2)
        }
    }
}
foreach($junctionBox in $junctionBoxes.Where({$_.inCircuitBox -eq $false})){
    $circuit = [Circuit]::new()
    $circuit.AddJunctionBox($junctionBox)
    $circuits.Add($circuit)
}

$productTop3 = 1
($circuits | sort-object {$_.junctionBoxes.Count} -Descending)[0..2] | ForEach-Object {
    $productTop3 *=$_.junctionBoxes.Count
}
$productTop3