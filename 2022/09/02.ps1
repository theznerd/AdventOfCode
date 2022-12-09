$input = Get-Content $PSScriptRoot\input.txt

class Knot
{
    [int]$x
    [int]$y
    Knot($x,$y){$this.x = $x; $this.y = $y}
    [void]GetNewPosition($h)
    {
        if([Math]::Abs($h.x - $this.x) -eq 2 -and $h.y -eq $this.y) ## we're two positions away on the x
        {
            if($h.x -lt $this.x){$this.x--}
            else{$this.x++}
        }
        elseif([Math]::Abs($h.y - $this.y) -eq 2 -and $h.x -eq $this.x) ## we're two positions away on the y
        {
            if($h.y -lt $this.y){$this.y--}
            else{$this.y++}
        }
        elseif([Math]::Abs($h.x - $this.x) -eq 2 -and [Math]::Abs($h.y - $this.y) -eq 1) ## we're two positions away on x, and one position away on y
        {
            $this.y = $h.y ## always pull to the row
            if($h.x -lt $this.x){$this.x--}
            else{$this.x++}
        }
        elseif([Math]::Abs($h.y - $this.y) -eq 2 -and [Math]::Abs($h.x - $this.x) -eq 1) ## we're two positions away on y, and one position away on x
        {
            $this.x = $h.x ## always pull to the column
            if($h.y -lt $this.y){$this.y--}
            else{$this.y++}
        }
        elseif([Math]::Abs($h.y - $this.y) -eq 2 -and [Math]::Abs($h.x - $this.x) -eq 2) ## we have to pull diagonal
        {
            if($h.y -lt $this.y){$this.y--}
            else{$this.y++}
            if($h.x -lt $this.x){$this.x--}
            else{$this.x++}
        }
    }
}

class Move
{
    [string]$direction
    [int]$moves
    Move($d,$m){$this.direction = $d; $this.moves = $m}
}

## convert moves
$moves = [System.Collections.Generic.List[Move]]@()
foreach($move in $input)
{   
    $d, $m = $move.Split(" ")
    [void]$moves.Add([Move]::new($d,$m))
}

$tPositions = [System.Collections.Generic.List[string]]@()

$h = [Knot]::new(0,0)
$k1 = [Knot]::new(0,0)
$k2 = [Knot]::new(0,0)
$k3 = [Knot]::new(0,0)
$k4 = [Knot]::new(0,0)
$k5 = [Knot]::new(0,0)
$k6 = [Knot]::new(0,0)
$k7 = [Knot]::new(0,0)
$k8 = [Knot]::new(0,0)
$k9 = [Knot]::new(0,0)

foreach($move in $moves)
{
    for($m = 0; $m -lt $move.moves; $m++)
    {
        switch($move.direction)
        {
            "R" {
                $h.x++
                break
            }
            "L" {
                $h.x--
                break
            }
            "D" {
                $h.y--
                break
            }
            "U" {
                $h.y++
                break
            }
        }

        # evaluate new knot positions
        #Write-Output "H Pos: $($h.x),$($h.y)"
        $k1.GetNewPosition($h)#; Write-Output "K1 Pos: $($k1.x),$($k1.y)"
        $k2.GetNewPosition($k1)#; Write-Output "K2 Pos: $($k2.x),$($k2.y)"
        $k3.GetNewPosition($k2)#; Write-Output "K3 Pos: $($k3.x),$($k3.y)"
        $k4.GetNewPosition($k3)#; Write-Output "K4 Pos: $($k4.x),$($k4.y)"
        $k5.GetNewPosition($k4)#; Write-Output "K5 Pos: $($k5.x),$($k5.y)"
        $k6.GetNewPosition($k5)#; Write-Output "K6 Pos: $($k6.x),$($k6.y)"
        $k7.GetNewPosition($k6)#; Write-Output "K7 Pos: $($k7.x),$($k7.y)"
        $k8.GetNewPosition($k7)#; Write-Output "K8 Pos: $($k8.x),$($k8.y)"
        $k9.GetNewPosition($k8)#; Write-Output "K9 Pos: $($k9.x),$($k9.y)"
        #Write-Output "--"

        [void]$tPositions.Add("$($k9.x),$($k9.y)")
    }
}

($tPositions | select -unique).Count