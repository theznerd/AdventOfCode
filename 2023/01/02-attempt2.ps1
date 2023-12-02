#$puzzleInput = Get-Content $PSScriptRoot\example2.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

enum singleDigits {
    zero
    one
    two
    three
    four
    five
    six
    seven
    eight
    nine
}

# This doesn't do what we expect... because all the numbers are valid threeight should be 38 not 3ight
<#
function Update-Digits ($string) {
    $regx = '(one|two|three|four|five|six|seven|eight|nine)'
    $newString = $string -replace $regx, {"$([int][singleDigits]::$($_))"}
    if($newString -eq $string){return $newString}
    else{Update-Digits $newString}
}
#>

# Only a single character would overlap, and we only need to replace the first and last instance
function Update-Digits ($string) {
    $regx = [regex]'(?=(one|two|three|four|five|six|seven|eight|nine))'
    $numbers = $regx.Matches($string)
    if($numbers)
    {
        $firstMatch = $numbers[0].Groups[1].Value
        $firstIndex = $numbers[0].Groups[1].Index
        $lastMatch = $numbers[-1].Groups[1].Value
        $lastIndex = $numbers[-1].Groups[1].Index
        return $string.Insert($firstIndex, [int][singleDigits]::$firstMatch).Insert(($lastIndex + 1), [int][singleDigits]::$lastMatch)
    }
    return $string
}

$calibrationValue = 0
foreach($line in $puzzleInput){
    $rline = (Update-Digits $line)
    $regx = [regex]'(\d)'
    $numbers = $regx.Matches($rline)
    $calibrationValue += [int]"$($numbers[0].Value)$($numbers[-1].Value)"
}
$calibrationValue
