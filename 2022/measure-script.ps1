$day = Read-Host -Prompt "Day"
$script = Read-Host -Prompt "Puzzle"

if($day.Length -eq 1){$day = "0$day"}
if($script.Length -eq 1){$script = "0$script"}

Measure-Command {Invoke-Expression "$PSScriptRoot\$day\$script.ps1"}