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
    $regx = '(one|two|three|four|five|six|seven|eight|nine)'
    $newString = $string -replace $regx, {"$([int][singleDigits]::$($_))$_"}
    
    ## Ugh... reverse matching? I don't like this solution...
    $words = "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"
    $lastIndex = -1
    $lastLength = 0
    $lastValue = ""
    foreach($word in $words)
    {
        $index = $newString.LastIndexOf($word)
        if($index -gt $lastIndex){$lastIndex = $index; $lastLength = $word.Length; $lastValue = $word}
    }
    if($lastIndex -eq -1){
        return $newString
    }
    if($lastIndex -eq 0){
        return "$([int][singleDigits]::$lastValue)$($newString[($lastLength)..($newString.Length)] -join '')"
    }
    if($lastIndex -gt 0){
        return "$($newString[0..$lastIndex] -join '')$([int][singleDigits]::$lastValue)$($newString[($lastIndex + $lastLength)..($newString.Length)] -join '')"
    }
}

$calibrationValue = 0
foreach($line in $puzzleInput){
    $rline = (Update-Digits $line)
    $regx = [regex]'(\d)'
    $numbers = $regx.Matches($rline)
    $calibrationValue += [int]"$($numbers[0].Value)$($numbers[-1].Value)"
}
$calibrationValue
