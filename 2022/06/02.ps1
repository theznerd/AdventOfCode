$input = (Get-Content $PSScriptRoot\input.txt).ToCharArray()

for($i = 14; $i -lt $input.Count; $i++)
{
    if(($input[($i-14)..($i-1)] | Select-Object -Unique).count -eq 14)
    {
        return "Start of Message: $i"
    }
}