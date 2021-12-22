## This is hella slow
## But it was fast enough to let me see
## what part two brought to the table
## and frankly it's exactly what I
## expected :(
$puzzleInput = Get-Content 'C:\Users\Nathan Ziehnert\OneDrive - Z-Nerd\Documents\AOC\2021\22\input.txt'

Class InitializationStep
{
    [bool]$on
    [int[]]$xRange
    [int[]]$yRange
    [int[]]$zRange
}
$initializationSteps = [System.Collections.ArrayList]::new()

foreach($step in $puzzleInput)
{
    $firstSplit = $step.Split(" ")
    $secondSplit = $firstSplit[1].Split(",")

    $istep = [InitializationStep]::new()
    $istep.on = if($firstSplit[0] -eq "on"){$true}else{$false}
    $istep.xRange = Invoke-Expression $secondSplit[0].Replace("x=","")
    $istep.yRange = Invoke-Expression $secondSplit[1].Replace("y=","")
    $istep.zRange = Invoke-Expression $secondSplit[2].Replace("z=","")
    [void]$initializationSteps.Add($istep)
}

$onCubes = @{}
$stepCount = 1
foreach($step in $initializationSteps)
{
    Write-Host "Round $stepCount... FIGHT!"
    if($step.xRange.Where({$_ -in (-50..50)}).Count -gt 0 `
       -or $step.yRange.Where({$_ -in (-50..50)}).Count -gt 0 `
       -or $step.zRange.Where({$_ -in (-50..50)}).Count -gt 0)
    {
        $xRange = $step.xRange.Where({$_ -ge -50 -and $_ -le 50})
        $yRange = $step.yRange.Where({$_ -ge -50 -and $_ -le 50})
        $zRange = $step.zRange.Where({$_ -ge -50 -and $_ -le 50})
        foreach($x in $xRange)
        {
            foreach($y in $yRange)
            {
                foreach($z in $zRange)
                {
                    if($step.on)
                    {
                        if(!$onCubes["$x,$y,$z"])
                        {
                            $onCubes.Add("$x,$y,$z",$true)
                        }
                    }
                    else
                    {
                        if($onCubes["$x,$y,$z"])
                        {
                            $onCubes.Remove("$x,$y,$z")
                        }
                    }
                }
            }
        }
    }
    $stepCount++
}
$onCubes.Count
