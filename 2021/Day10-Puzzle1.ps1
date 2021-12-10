$puzzleInput = Get-Content 'C:\Users\Nathan Ziehnert\OneDrive - Z-Nerd\Documents\AOC\2021\10\input.txt'

$syntax = @(
    [pscustomobject]@{Open = "["; Close="]"; Value=57}
    [pscustomobject]@{Open = "("; Close=")"; Value=3}
    [pscustomobject]@{Open = "<"; Close=">"; Value=25137}
    [pscustomobject]@{Open = "{"; Close="}"; Value=1197}
)

function BreakdownSyntax($string)
{
    $newString = $string
    foreach($pair in $syntax)
    {
        $newString = $newString -Replace "\$($pair.Open)\$($pair.Close)",""
    }
    if($newString.Length -lt $string.Length)
    {
        $newString = BreakdownSyntax($newString)
    }
    return $newString
}

function ValidateSyntax($string)
{
    $closeIndex = $string.IndexOfAny($syntax.Close)
    if($string[$closeIndex] -ne $string[$closeIndex-1])
    {
        return $syntax.Where({$_.Close -eq $string[$closeIndex]}).Value
    }
}

## Main script
$score = 0
foreach($input in $puzzleInput)
{
    $score += ValidateSyntax $(BreakdownSyntax $input)
}
$score
