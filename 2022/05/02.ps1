$input = Get-Content $PSScriptRoot\input.txt

$stackListLine = ($input | Select-String -Pattern "^( *)\d").LineNumber
$stackArray = ($input[($stackListLine-1)]).Split("   ").Replace(" ","")

$stackHash = @{}
foreach($stack in $stackarray)
{
    $stackHash.Add($stack, [System.Collections.Generic.Stack[object]]::new())
}

for($i = ($stackListLine-2); $i -ge 0; $i--)
{
    $s = 1
    for($c = 1; $c -lt $input[$i].Length; $c = $c+4)
    {
        if(-not [string]::IsNullOrWhiteSpace(($input[$i].ToCharArray())[$c]))
        {
            [void]$stackHash["$s"].Push(($input[$i].ToCharArray())[$c])
        }
        $s++
    }
}

$instructions = $input[($stackListLine+1)..$input.Length]
foreach($instruction in $instructions)
{
    $null, $count, $null, $source, $null, $dest = $instruction.Split(" ")
    $popStack = [System.Collections.Generic.Stack[object]]::new()
    for($m = 0; $m -lt $count; $m++)
    {
        [void]$popStack.Push($stackHash["$source"].Pop())
    }
    foreach($p in $popStack)
    {
        [void]$stackHash["$dest"].Push($p)
    }
}

$outputString = ""
for($i = 1; $i -le $stackHash.Count; $i++)
{
    $outputString += $stackHash["$i"].Pop()
}
$outputString