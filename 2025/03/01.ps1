#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

$outputJoltage = 0
foreach($bank in $puzzleInput)
{
    $maxFirstValue = 0
    $maxFirstIndex = 0
    for($i = 0; $i -lt ($bank.Length - 1); $i++)
    {
        if([Int]::Parse($bank[$i]) -gt $maxFirstValue)
        {
            $maxFirstValue = [Int]::Parse($bank[$i])
            $maxFirstIndex = $i
        }
    }

    $maxSecondValue = 0
    for($i = $maxFirstIndex + 1; $i -lt $bank.Length; $i++)
    {
        if([Int]::Parse($bank[$i]) -gt $maxSecondValue)
        {
            $maxSecondValue = [Int]::Parse($bank[$i])
        }
    }
    $outputJoltage += [Int]::Parse("$maxValue$maxSecondValue")
}
$outputJoltage