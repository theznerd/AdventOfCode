$puzzleInput = Get-Content $PSScriptRoot\input.txt

class Packet : System.IComparable {
    [int]$packetInitialId
    [int]$packetCorrectId
    [System.Array]$packetContents
    Packet([string]$PacketString, [int]$packetId)
    {
        $this.packetInitialId = $packetId
        $this.packetContents = $PacketString | ConvertFrom-Json -NoEnumerate
    }

    [int] CompareTo($rightPacket)
    {
        $result = [Packet]::CompareList($this.packetContents, $rightPacket.packetContents)
        switch($result)
        {
            1 {return -1; break}
            0 {return 1; break}
            default {return 0}
        }
        return 0;
    }

    hidden static [int]CompareList([Array]$leftArray,[Array]$rightArray)
    {
        ## this is where the bulk of the work comes into play,
        ## because we can easily recurse this
        for($i = 0; $i -lt [Math]::Max($leftArray.Count, $rightArray.Count); $i++)
        {
            if($null -eq $leftArray[$i] -and $null -ne $rightArray[$i])
            {
                return 1
            }
            elseif($null -eq $rightArray[$i] -and $null -ne $leftArray[$i])
            {
                return 0
            }
            elseif($leftArray[$i] -is [int64] -and $rightArray[$i] -is [int64])
            {
                switch([Packet]::CompareInt($leftArray[$i],$rightArray[$i]))
                {
                    1 { return 1; break}
                    0 { return 0; break}
                    -1 { continue; }
                }
            }
            elseif($leftArray[$i] -is [System.Array] -and $rightArray[$i] -is [System.Array])
            {
                switch([Packet]::CompareList($leftArray[$i], $rightArray[$i]))
                {
                    1 { return 1; break}
                    0 { return 0; break}
                    -1 { continue; }
                }
            }
            elseif($leftArray[$i] -is [int64] -or $rightArray[$i] -is [int64])
            {
                $la = $leftArray[$i]
                if($la -is [int64]){$la = @($la)}

                $ra = $rightArray[$i]
                if($ra -is [int64]){$ra = @($ra)}

                switch([Packet]::CompareList($la,$ra))
                {
                    1 { return 1; break}
                    0 { return 0; break}
                    -1 { continue; }
                }
            }
            else
            {
                Write-Output "Logic broken"
                return -1000
            }
        }
        Write-Output "Logic Really Broken"
        return -1000   
    }

    hidden static [int]CompareInt([int]$leftInt,[int]$rightInt)
    {
        if($leftInt -gt $rightInt){
            return 0 ## incorrect order
        }
        elseif($rightInt -gt $leftInt){
            return 1 ## correct order
        }
        else{
            return -1 ## equality, continue
        }
    }
}

## Create some objects
$packets = [System.Collections.Generic.List[Packet]]@()
$i = 0
foreach($p in $puzzleInput)
{
    if([String]::IsNullOrWhiteSpace($p)){continue}
    $i++
    [void]$packets.Add([Packet]::new($p,$i))
}
$packetTwo = [Packet]::new("[[2]]",$i+1)
$packetSix = [Packet]::new("[[6]]",$i+2)
$packets.Add($packetSix)
$packets.Add($packetTwo)

$packets.Sort()

($packets.IndexOf($packetTwo)+1)*($Packets.IndexOf($packetSix)+1)