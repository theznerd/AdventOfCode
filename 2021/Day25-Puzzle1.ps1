## This is horridly slow... but it worked... :)
## Was fun being able to use object references
## to make the class methods do what they needed
$puzzleInput = Get-Content 'C:\Users\Nathan Ziehnert\OneDrive - Z-Nerd\Documents\AOC\2021\25\input.txt'

Class SouthCucumber
{
    [int]$x
    [int]$y
    SouthCucumber($x,$y)
    {
        $this.x = $x
        $this.y = $y
    }
    [bool]CanMoveForward($puzzleMap)
    {
        $nextPosition = ($this.y+1)%$puzzleMap.GetLength(1)
        return $puzzleMap[$this.x,$nextPosition] -eq "."
    }
    MoveForward($puzzleMap)
    {
        $nextPosition = ($this.y+1)%$puzzleMap.GetLength(1)
        $puzzleMap[$this.x,$nextPosition] = $this
        $puzzleMap[$this.x,$this.y] = "."
        $this.y = $nextPosition
    }
}

Class EastCucumber
{
    [int]$x
    [int]$y
    EastCucumber($x,$y)
    {
        $this.x = $x
        $this.y = $y
    }
    [bool]CanMoveForward($puzzleMap)
    {
        $nextPosition = ($this.x+1)%$puzzleMap.GetLength(0)
        return $puzzleMap[$nextPosition,$this.y] -eq "."
    }
    MoveForward($puzzleMap)
    {
        $nextPosition = ($this.x+1)%$puzzleMap.GetLength(0)
        $puzzleMap[$nextPosition,$this.y] = $this
        $puzzleMap[$this.x,$this.y] = "."
        $this.x = $nextPosition
    }
}

$puzzleXMax = $puzzleInput[0].Length
$puzzleYMax = $puzzleInput.Count
$puzzleMap = New-Object 'object[,]' $puzzleXMax,$puzzleYMax
for($y = 0; $y -lt $puzzleYMax; $y++)
{
    for($x = 0; $x -lt $puzzleXMax; $x++)
    {
        $space = ($puzzleInput[$y].ToCharArray())[$x]
        switch($space)
        {
            "v" {$puzzleMap[$x,$y] = [SouthCucumber]::new($x,$y)}
            "." {$puzzleMap[$x,$y] = "."}
            ">" {$puzzleMap[$x,$y] = [EastCucumber]::new($x,$y)}
        }
    }
}

$movingAnything = $true
$i = 0
while($movingAnything)
{
    $i++
    $movingAnything = $false
    
    # Move all east cucumbers
    $cucumbersToMove = $puzzleMap.Where({$_.GetType().Name -eq "EastCucumber" -and $_.CanMoveForward($puzzleMap)})
    if($cucumbersToMove.Count -gt 0)
    {
        $movingAnything = $true
    }
    $cucumbersToMove | %{$_.MoveForward($puzzleMap)}

    # Move all south cucumbers
    $cucumbersToMove = $puzzleMap.Where({$_.GetType().Name -eq "SouthCucumber" -and $_.CanMoveForward($puzzleMap)})
    if($cucumbersToMove.Count -gt 0)
    {
        $movingAnything = $true
    }
    $cucumbersToMove | %{$_.MoveForward($puzzleMap)}
}
Write-Host $i

## function to print map for debug
function PrintMap($puzzleMap)
{
    for($y = 0; $y -lt $puzzleMap.GetLength(1); $y++)
    {
        $string = ""
        for($x = 0; $x -lt $puzzleMap.GetLength(0); $x++)
        {
            switch($puzzleMap[$x,$y].GetType().Name)
            {
                "EastCucumber" {$string += ">"}
                "SouthCucumber" {$string += "v"}
                "String" {$string += "."}
            }
        }
        Write-Host $string
    }
}
