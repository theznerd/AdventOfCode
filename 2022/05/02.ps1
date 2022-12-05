$input = Get-Content $PSScriptRoot\input.txt

$stackListLine = ($input | Select-String -Pattern "^( *)\d").LineNumber
$stackArray = ($input[($stackListLine-1)]).Split("   ").Replace(" ","")

$stackHash = @{}
foreach($stack in $stackarray)
{
    $blankList = [System.Collections.Generic.List[object]]@()
    $stackHash.Add($stack, $blankList)
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
    $movingCrates = $stackHash["$source"][(-$count)..-1]
    $stackHash["$source"].RemoveRange($stackHash["$source"].Count-$count,$count)
    $stackHash["$dest"].AddRange($movingCrates)
}

$outputString = ""
for($i = 1; $i -le $stackHash.Count; $i++)
{
    $outputString += $stackHash["$i"][-1]
}
$outputString