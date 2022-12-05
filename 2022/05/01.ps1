$input = Get-Content $PSScriptRoot\input.txt

$stackListLine = ($input | Select-String -Pattern "^( *)\d").LineNumber
$stackArray = ($input[($stackListLine-1)]).Split("   ").Replace(" ","")

$stackHash = @{}
foreach($stack in $stackarray)
{
    $stackHash.Add($stack, [System.Collections.Generic.List[object]]@())
}

for($i = ($stackListLine-2); $i -ge 0; $i--)
{
    $s = 1
    for($c = 1; $c -lt $input[$i].Length; $c = $c+4)
    {
        if(-not [string]::IsNullOrWhiteSpace(($input[$i].ToCharArray())[$c]))
        {
            $stackHash["$s"].Add(($input[$i].ToCharArray())[$c])
        }
        $s++
    }
}

$instructions = $input[($stackListLine+1)..$input.Length]
foreach($instruction in $instructions)
{
    $null, $count, $null, $source, $null, $dest = $instruction.Split(" ")
    for($m = 0; $m -lt $count; $m++)
    {
        $movingCrate = $stackHash["$source"][-1]
        $stackHash["$source"].RemoveAt(($stackHash["$source"].Count-1))
        $stackHash["$dest"].Add($movingCrate)
    }
}

$outputString = ""
for($i = 1; $i -le $stackHash.Count; $i++)
{
    $outputString += $stackHash["$i"][-1]
}
$outputString