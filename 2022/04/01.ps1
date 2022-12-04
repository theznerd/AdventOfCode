$input = Get-Content $PSScriptRoot\input.txt

$fullOverlaps = 0
foreach($pair in $input)
{
    ## this was cute... but slow as hell
    <#
    $elfone, $elftwo = $pair.Split(',')
    $elfone = @(iex ($elfone.Replace("-","..")))
    $elftwo = @(iex ($elftwo.Replace("-","..")))
    
    if($elfone.count -ge $elftwo.count){
        if((($elfOne + $elftwo) | Select-Object -Unique).Count -eq $elfOne.Count){$fullOverlaps++}
    }
    else{
        if((($elfOne + $elftwo) | Select-Object -Unique).Count -eq $elftwo.Count){$fullOverlaps++}
    }
    #>

    ## this is still slow as hell
    <#
    $elfoneLow, $elfoneHigh, $elftwoLow, $elftwoHigh = $pair.Split(',').Split('-')
    [int[]]$elfone = $elfoneLow..$elfoneHigh
    [int[]]$elftwo = $elftwoLow..$elftwoHigh
    if($elfone.count -ge $elftwo.count)
    {
        if(-not @($elftwo| where {$elfone -notcontains $_}).Count){$fullOverlaps++}
    }
    else
    {
        if(-not @($elfone| where {$elftwo -notcontains $_}).Count){$fullOverlaps++}
    }
    #>

    ## of course the others were slow as hell
    ## forgot these were ranges, not random
    ## assignments... I was previously attempting
    ## to cover situations where an elf could be
    ## assigned 1,2,5 and not 1,2,3,4,5
    [int]$elfoneLow, [int]$elfoneHigh, [int]$elftwoLow, [int]$elftwoHigh = $pair.Split(',').Split('-')
    if(($elfoneLow -ge $elftwoLow -and $elfoneHigh -le $elftwoHigh) -or
       ($elftwolow -ge $elfoneLow -and $elftwohigh -le $elfoneHigh))
    {
        $fullOverlaps++
    }
}
$fullOverlaps