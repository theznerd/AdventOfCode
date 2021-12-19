$puzzleInput = Get-Content 'C:\Users\Nathan Ziehnert\OneDrive - Z-Nerd\Documents\AOC\2021\18\input.txt'

Function Invoke-AddNumber($n1, $n2)
{
    return "[$n1,$n2]"
}

Function Invoke-SplitNumber($string, $index)
{
    $numberToSplit = [regex]::Matches($string, "\d{1,}").Where({$_.Index -eq $index})
    
    $integer = [int]::Parse($numberToSplit.Value)
    $newLeft = [Math]::Floor($integer/2)
    $newRight = [Math]::Ceiling($integer/2)

    return $string.Remove($index, $numberToSplit.Length).Insert($index, "[$newLeft,$newRight]")
}

Function Invoke-ExplodeNumber($string, $index)
{
    $pairToExplode = [regex]::Matches($string, "\[\d{1,},\d{1,}\]").Where({$_.Index -eq $index})

    $leftNumber = [int]::Parse($pairToExplode.Value.Replace("[","").Replace("]","").Split(",")[0])
    $rightNumber = [int]::Parse($pairToExplode.Value.Replace("[","").Replace("]","").Split(",")[1])
    
    $leftRegularNumberIndex = Get-RegularNumberIndex $string ($index+1) "L" # start the search including the first char of the exploding pair
    if($leftRegularNumberIndex)
    {
        $lrnLength = [regex]::Matches($string, "\d{1,}").Where({$_.Index -eq $leftRegularNumberIndex})[0].Length
        $newlrNumber = [int]::Parse(($string[$leftRegularNumberIndex..($leftRegularNumberIndex+$lrnLength-1)]-join'')) + $leftNumber
        $string = $string.Remove($leftRegularNumberIndex, $lrnLength).Insert($leftRegularNumberIndex, $newlrNumber)
        $index = $index + ($newlrNumber.ToString().Length - $lrnLength) # If we end up going from single digit to two or more digits, we need to shift the index right
    }
    
    $rightRegularNumberIndex = Get-RegularNumberIndex $string ($index+$pairToExplode.Value.Length-2) "R" # start the search including the last char of the exploding pair
    if($rightRegularNumberIndex)
    {
        $rrnLength = [regex]::Matches($string, "\d{1,}").Where({$_.Index -eq $rightRegularNumberIndex})[0].Length
        $newrrNumber = [int]::Parse(($string[$rightRegularNumberIndex..($rightRegularNumberIndex+$rrnLength-1)]-join'')) + $rightNumber
        ## we don't need to shift the index here, because the final replace 
        ## of [\d{1,},\d{1,}] will be to the left of this index change
        $string = $string.Remove($rightRegularNumberIndex, $rrnLength).Insert($rightRegularNumberIndex, $newrrNumber)
    }
    
    #replace the [\d{1,},\d{1,}] with 0
    $lengthOfPair = $pairToExplode.Length
    $string = $string.Remove($index, $lengthOfPair).Insert($index, "0")
    
    return $string
}

Function Get-RegularNumberIndex($string, $index, $direction)
{
    $allRegularNumbers =  [regex]::Matches($string, "(?=\[(\d{1,}),\[)").Groups.Where({$_.Length -ne 0}) # we probably shouldn't ever have more than a 2 digit number, make it 3 to be safe
    $allRegularNumbers += [regex]::Matches($string, "(?=\],(\d{1,})\])").Groups.Where({$_.Length -ne 0}) # we probably shouldn't ever have more than a 2 digit number, make it 3 to be safe
    $allRegularNumbers += [regex]::Matches($string, "\[(\d{1,}),(\d{1,})\]").Groups.Where({$_.Length -lt 4})

    if($direction -eq "L")
    {
        $allRegularNumbersLeft = ($allRegularNumbers.Where({$_.Index -lt $index}) | Sort-Object Index -Descending)
        if($allRegularNumbersLeft.Count -gt 0)
        {
            return $allRegularNumbersLeft[0].Index
        }
    }
    else
    {
        $allRegularNumbersRight = ($allRegularNumbers.Where({$_.Index -gt $index}) | Sort-Object Index)
        if($allRegularNumbersRight.Count -gt 0)
        {
            return $allRegularNumbersRight[0].Index
        }
    }
}

Function Invoke-ReduceNumber($string)
{
    $newString = $string
    do
    {
        $originalString = $newString
        #explode
        $exploded = $false
        $index = 0
        $depth = 0
        for($i = 0; $i -lt $newString.Length; $i++)
        {
            if    ($newString[$i] -eq "["){$depth++}
            elseif($newString[$i] -eq "]"){$depth--}
            if($depth -eq 5){$exploded = $true; break}
            $index++
        }
        if($exploded)
        {
            $newString = Invoke-ExplodeNumber $newString $index
            $exploded = $true
        }
        
        #split
        if(!$exploded) # We didn't explode, so now we can check for splits
        {
            $splitFind = [regex]::Match($newString, "\d{2}")
            if($splitFind.Success)
            {
                $newString = Invoke-SplitNumber $newString $splitFind.Index
            }
        }
    }until($newString -eq $originalString)
    return $newString
}

Function Get-NumberMagnitude($number)
{
    $pair = [regex]::Match($number, "\[\d{1,},\d{1,}\]")
    do{
        $leftNumber = [int]::Parse($pair.Value.Replace("[","").Replace("]","").Split(",")[0])*3
        $rightNumber = [int]::Parse($pair.Value.Replace("[","").Replace("]","").Split(",")[1])*2
        $number = $number.Remove($pair.Index, $pair.Length).Insert($pair.Index, ($leftNumber+$rightNumber).ToString())
        $pair = [regex]::Match($number, "\[\d{1,},\d{1,}\]")
    }while($pair.Success)
    
    return $number
}

$numberToReduce = Invoke-AddNumber $puzzleInput[0] $puzzleInput[1]
$finalSum = Invoke-ReduceNumber $numberToReduce
for($i = 2; $i -lt $puzzleInput.Count; $i++)
{
    $finalSum = Invoke-AddNumber $finalSum $puzzleInput[$i]
    $finalSum = Invoke-ReduceNumber $finalSum
}
$finalSum
Get-NumberMagnitude $finalSum
