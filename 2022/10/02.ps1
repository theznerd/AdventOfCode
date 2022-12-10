$input = Get-Content $PSScriptRoot\input.txt

$script:cycle = 0
$script:register = 1 ## sprite position
$script:screen = New-Object "string[,]" 6,40

function Invoke-StepCycle {
    if(($cycle % 40) -in (($script:register - 1), $script:register, ($script:register + 1)))
    {
        $script:screen[([Math]::Floor($cycle/40)),($cycle % 40)] = "#"
    }
    $script:cycle++
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

Function Invoke-DrawScreen($screen)
{
    for($r = 0; $r -lt 6; $r++)
    {
        $row = ""
        for($c = 0; $c -lt 40; $c++)
        {
            if([string]::IsNullOrEmpty("$($screen[$r,$c])"))
            {
                $row += " "
            }
            else
            {
                $row += "#"
            }
        }
        Write-Output $row
    }
}
Invoke-DrawScreen($script:screen)