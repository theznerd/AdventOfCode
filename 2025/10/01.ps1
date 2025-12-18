#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

class Machine {
    [Lights]$lights
    [Collections.Generic.List[Switch]]$switches = [Collections.Generic.List[Switch]]::new()
    [int]$fewestPresses = [int]::MaxValue
}

class Lights {
    [int]$requiredLightSequence
    [int]$lightCount = 0
    [hashtable]$lightJoltageRequirements = @{}
}

class Switch {
    [int]$lightSequenceMask = 0 # binary mask of which lights this switch controls   
}

$regex = "\[(.*)\]|\(([\d|,]*?)\)|{(.*)}"
[Collections.Generic.List[Machine]]$machines = [Collections.Generic.List[Machine]]::new()
foreach($pir in $puzzleInput){
    $machine = [Machine]::new()
    $puzzleRow = [regex]::Matches($pir, $regex)
    [Lights]$rowlights = [Lights]::new()
    $rowlights.requiredLightSequence = [Convert]::ToInt32($puzzleRow[0].Groups[1].Value.Replace('.','0').Replace('#','1'), 2)
    $rowlights.lightCount = $puzzleRow[0].Groups[1].Value.Length
    $joltageRequirements = $puzzleRow[-1].Groups[3].Value -split ","
    for($i = 0; $i -lt $joltageRequirements.Count; $i++){
        $rowlights.lightJoltageRequirements[$i] = [Int]$joltageRequirements[$i]
    }
    $machine.lights = $rowlights
    
    foreach($s in $puzzleRow[1..($puzzleRow.Count - 2)]){
        [switch]$rowswitch = [switch]::new()
        $sw = $s.Groups[2].Value -split ","
        for($i = 0; $i -lt $rowlights.lightCount; $i++){
            if($i -in $sw){
                $rowswitch.lightSequenceMask += [math]::Pow(2, $rowlights.lightCount - $i - 1)
            }
        }
        $machine.switches.Add($rowswitch)
    }
    $machines.Add($machine)
}

## Pressing swtiches twice is the same as not pressing them at all
## So presumably for now we only need to consider pressing each switch once or 
## not at all
## An "efficient" test pattern would be to start from lowest number of presses
## and work up, but the search space is small enough we'll just brute force it
foreach($machine in $machines)
{
    $n = $machine.switches.Count
    for ($i = 0; $i -lt (1 -shl $n); $i++) {
        $xor = 0
        for($bit = 0; $bit -lt $n; $bit++){
            if($i -band (1 -shl $bit)){
                $xor = $xor -bxor $machine.switches[$bit].lightSequenceMask
            }
        }
        if($xor -eq $machine.lights.requiredLightSequence){
            $machine.fewestPresses = [math]::Min($machine.fewestPresses, [System.Numerics.BitOperations]::PopCount($i))
        }
    }
}
$machines.fewestPresses | Measure-Object -Sum | Select-Object -ExpandProperty Sum