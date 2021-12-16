Measure-Command {
$puzzleInput = Get-Content 'C:\Users\Nathan Ziehnert\OneDrive - Z-Nerd\Documents\AOC\2021\16\input.txt'
$binarySB = [System.Text.StringBuilder]::new()
$puzzleInput.ToCharArray() | %{
    [void]$binarySB.Append($(switch($_)
    {
        0 {"0000"; break}
        1 {"0001"; break}
        2 {"0010"; break}
        3 {"0011"; break}
        4 {"0100"; break}
        5 {"0101"; break}
        6 {"0110"; break}
        7 {"0111"; break}
        8 {"1000"; break}
        9 {"1001"; break}
        A {"1010"; break}
        B {"1011"; break}
        C {"1100"; break}
        D {"1101"; break}
        E {"1110"; break}
        F {"1111"; break}
    }))
}
$BinaryStringArray = $binarySB.ToString().ToCharArray()

Class Packet
{
    [int]$Version
    [int]$Type
    [string]$StringValue # Used only for type 4 packets
    [Packet[]]$SubPackets = [System.Collections.ArrayList]::new()
    [long]$FinalValue
}

#region packetparser
$parsingScripts = @{}

$parsingScripts.Add(0,{
    # sum of the values of subpackets
    param($p)
    [long]$value = 0
    $p.SubPackets.FinalValue | %{$value += $_}
    return $value})

$parsingScripts.Add(1,{
    # product of values of subpackets
    param($p)
    $subValues = $p.SubPackets.FinalValue
    [long]$value = $subValues[0]
    $subValues[1..$subValues.Count] | %{$value = $value*$_}
    return $value})

$parsingScripts.Add(2,{
    # minimum value of subpackets
    param($p)
    return (($p.SubPackets.FinalValue | Sort-Object)[0])})

$parsingScripts.Add(3,{
    # maximum value of subpackets
    param($p)
    return (($p.SubPackets.FinalValue | Sort-Object)[-1])})

$parsingScripts.Add(4,{
    # literal value
    param($p)
    return [convert]::ToInt64($p.StringValue,2)})

$parsingScripts.Add(5,{
    # if subpacket[0] -gt subpacket[1] return 1, else 0
    # always have two sub-packets
    param($p)
    if($p.SubPackets[0].FinalValue -gt $p.SubPackets[1].FinalValue)
    {return 1}else{return 0}})

$parsingScripts.Add(6,{
    # always have two sub-packets
    # if subpacket[0] -lt subpacket[1] return 1, else 0
    param($p)
    if($p.SubPackets[0].FinalValue -lt $p.SubPackets[1].FinalValue)
    {return 1}else{return 0}})

$parsingScripts.Add(7,{
    # always have two sub-packets
    # if subpacket[0] -eq subpacket[1] return 1, else 0
    param($p)
    if($p.SubPackets[0].FinalValue -eq $p.SubPackets[1].FinalValue)
    {return 1}else{return 0}})

function ParsePacketValue($packet)
{
    $packet.FinalValue = (&$parsingScripts[$packet.Type] -p $packet)
}
#endregion packetparser

## Turn the data into packets
function ParseData($dataInput, [ref]$returnedPacket)
{
    # Get header and type of packet
    $headerVersion = [convert]::ToInt32($dataInput[0..2]-join'',2)
    $headerType    = [convert]::ToInt32($dataInput[3..5]-join'',2)
    $dataInput = $dataInput[6..$dataInput.Count] # pop the header from the array

    # Create a new packet
    $packet = [Packet]::new()
    $packet.Type = $headerType
    $packet.Version = $headerVersion

    # Determine type of packet and process
    if($packet.Type -eq 4)
    {
        while($true){
            $continue = $dataInput[0]
            $packet.StringValue += $dataInput[1..4]-join'' # add 4 bits to the value
            $dataInput = $dataInput[5..$dataInput.Count] # pop the 5 bits from the array (continue?, value)
            if($continue -eq "0")
            {
                break
            }
        }
        $returnedPacket.Value = $packet
        ParsePacketValue $packet
    }
    else
    {
        $lengthType = $dataInput[0]
        if($lengthType -eq "0")
        {
            # grab 15 bits
            $totalLength = [Convert]::ToInt32($dataInput[1..15]-join'',2)
            $dataInput = $dataInput[16..$dataInput.Count] # pop out the length type and total length
            $subPacketData = $dataInput[0..($totalLength-1)] ## get the subpacket data
            while($subPacketData.Length -gt 0)
            {
                $subPacketData = ParseData $subPacketData $returnedPacket
                $packet.SubPackets += $returnedPacket.Value
            }
            $dataInput = $dataInput[$totalLength..$dataInput.Count] # pop the data that we just parsed
            $returnedPacket.Value = $packet
            ParsePacketValue $packet
        }
        else
        {
            # grab 11 bits
            $numberOfPackets = [Convert]::ToInt32($dataInput[1..11]-join'',2)
            $dataInput = $dataInput[12..$dataInput.Count] # pop the length type and number of packets
            for($i = 0; $i -lt $numberOfPackets; $i++)
            {
                $dataInput = ParseData $dataInput $returnedPacket
                $packet.SubPackets += $returnedPacket.Value
            }
            $returnedPacket.Value = $packet
            ParsePacketValue $packet
        }
    }
    return $dataInput # remaining data after parsing a packet
}
$finalReturnedPacket = $null
[void](ParseData $BinaryStringArray ([ref]$finalReturnedPacket))
$finalReturnedPacket.FinalValue
}
