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
}
$fullOverlaps