$puzzleInput = Get-Content $PSScriptRoot\input.txt -raw
$packetPairsInput = $puzzleInput -split "`r`n`r`n"

## Maybe this will be useful
class PacketPair {
    [int]$index
    [Packet]$leftPacket
    [Packet]$rightPacket
    [bool]$correctOrder = $false
    PacketPair($i,$l,$r)
    {
        $this.index = $i
        $this.leftPacket = $l
        $this.rightPacket = $r
    }
}

class Packet {
    [System.Array]$packetContents
    Packet([string]$PacketString)
    {
        $this.packetContents = $PacketString | ConvertFrom-Json -NoEnumerate
    }

    static [bool]ValidateOrder([Packet]$leftPacket, [Packet]$rightPacket)
    {
        return [Packet]::CompareList($leftPacket.packetContents, $rightPacket.packetContents)
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

    hidden static [Array]ConvertIntToArray([int]$int)
    {
        return @($int)
    }
}

## Create some objects
$packetPairs = [System.Collections.Generic.List[PacketPair]]@()
$i = 0
foreach($pp in $packetPairsInput)
{
    $i++
    $pp = $pp -split "`r`n"

    ## Generate packets
    # generate left packet
    $lp = [Packet]::new($pp[0])

    # generate right packet
    $rp = [Packet]::new($pp[1])

    ## Add Packets
    [void]$packetPairs.Add([PacketPair]::new($i,$lp,$rp))
}

## Okay now to get to the real work lol
foreach($packetPair in $packetPairs)
{
    $packetPair.correctOrder = [Packet]::ValidateOrder($packetPair.leftPacket, $packetPair.rightPacket)
}

$sumCorrectPacketIndexes = 0
foreach($p in $packetPairs.Where({$_.correctOrder}))
{
    $sumCorrectPacketIndexes += $p.index
}
$sumCorrectPacketIndexes