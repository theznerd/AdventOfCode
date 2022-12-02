$day = Read-Host -Prompt "Day"
$script = Read-Host -Prompt "Puzzle"
$optimized = Read-Host -Prompt "Optimized (y/n)"

if($day.Length -eq 1){$day = "0$day"}
if($script.Length -eq 1){$script = "0$script"}

if($optimized -eq "y")
{
    Measure-Command {Invoke-Expression "$PSScriptRoot\$day\$script-optimized.ps1"}
}
else
{
    Measure-Command {Invoke-Expression "$PSScriptRoot\$day\$script.ps1"}
}