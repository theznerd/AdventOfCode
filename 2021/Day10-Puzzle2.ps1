$puzzleInput = Get-Content 'C:\Users\Nathan Ziehnert\OneDrive - Z-Nerd\Documents\AOC\2021\10\input.txt'
$incompleteLines = @()

$syntax = @(
    [pscustomobject]@{Open = "["; Close="]"; Value=2}
    [pscustomobject]@{Open = "("; Close=")"; Value=1}
    [pscustomobject]@{Open = "<"; Close=">"; Value=4}
    [pscustomobject]@{Open = "{"; Close="}"; Value=3}
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
foreach($input in $puzzleInput)
{
    if((ValidateSyntax $(BreakdownSyntax $input)) -eq $null)
    {
       $incompleteLines += $(BreakdownSyntax $input)
    }
}

$scores = @()
foreach($incompleteLine in $incompleteLines)
{
    $completionString = $null
    foreach($char in $incompleteLine[($incompleteLine.ToCharArray().Count-1)..0])
    {
        $completionString += $syntax.Where({$_.Open -eq $char}).Close
    }
    $score = 0
    foreach($char in $completionString.ToCharArray())
    {
        $score = ($score*5) + $syntax.Where({$_.Close -eq $char}).Value
    }
    $scores += $score
}
($scores | sort)[[math]::Round($scores.Count/2)]
