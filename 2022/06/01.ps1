$input = (Get-Content $PSScriptRoot\input.txt).ToCharArray()

for($i = 4; $i -lt $input.Count; $i++)
{
    if(($input[($i-4)..($i-1)] | Select-Object -Unique).count -eq 4)
    {
        return "Start of Packet: $i"
    }
}