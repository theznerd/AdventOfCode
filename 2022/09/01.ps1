$input = Get-Content $PSScriptRoot\input.txt

class Head
{
    [int]$x
    [int]$y
    Head($x,$y){$this.x = $x; $this.y = $y}
}

class Tail
{
    [int]$x
    [int]$y
    Tail($x,$y){$this.x = $x; $this.y = $y}
    [void]GetNewPosition($h)
    {
        if([Math]::Abs($h.x - $this.x) -le 1 -and [Math]::Abs($h.y - $this.y) -le 1)
        {
            ## we're within the the spot where the tail doesn't move
        }
        elseif([Math]::Abs($h.x - $this.x) -eq 2 -and $h.y -eq $this.y) ## we're two positions away on the x
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
        else
        {
            throw "something went wrong... the tail is too far away from the head"
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

$h = [Head]::new(0,0)
$t = [Tail]::new(0,0)
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

        # evaluate new Tail position
        $t.GetNewPosition($h)

        # add tail position to $tPositions
        [void]$tPositions.Add("$($t.x),$($t.y)")
    }
}

($tPositions | select -Unique).Count