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
}

$packets = [System.Collections.ArrayList]::new()
function ParseData($dataInput)
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
            $dataInput = $dataInput[5..$dataInput.Count] # pop the 5 bits from the array (continue?, value)
            if($continue -eq "0")
            {
                break
            }
        }
        [void]$packets.Add($packet)
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
                $subPacketData = ParseData $subPacketData
            }
            $dataInput = $dataInput[$totalLength..$dataInput.Count] # pop the data that we just parsed
            [void]$packets.Add($packet)
        }
        else
        {
            # grab 11 bits
            $numberOfPackets = [Convert]::ToInt32($dataInput[1..11]-join'',2)
            $dataInput = $dataInput[12..$dataInput.Count] # pop the length type and number of packets
            for($i = 0; $i -lt $numberOfPackets; $i++)
            {
                $dataInput = ParseData $dataInput   
            }
            [void]$packets.Add($packet)
        }
    }
    return $dataInput # remaining data after parsing a packet
}
[void](ParseData $BinaryStringArray)

$versionCount = 0
$packets.Version | %{$versionCount += $_}
$versionCount
