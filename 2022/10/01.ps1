$input = Get-Content $PSScriptRoot\input.txt

$script:cycle = 0
$script:register = 1
$script:importantRegisterSum = 0

function Invoke-StepCycle {
    $script:cycle++
    if(($script:cycle - 20) % 40 -eq 0)
    {
        $script:importantRegisterSum += ($script:cycle * $script:register)
    }
}


foreach($instruction in $input)
{
    $op, [int]$val = $instruction -split " "
    switch($op)
    {
        "noop" {
            Invoke-StepCycle
            break
        }
        "addx" {
            Invoke-StepCycle
            Invoke-StepCycle
            $script:register += $val
        }

    }
}
$script:importantRegisterSum