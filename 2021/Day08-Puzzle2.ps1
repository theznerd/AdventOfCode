$puzzleInput = Get-Content 'C:\Users\Nathan Ziehnert\OneDrive - Z-Nerd\Documents\AOC\2021\08\input.txt'

$fourDigitSegments = @()
foreach($segment in $puzzleInput)
{
    $split = ($segment -Split ' \| ')
    $numbers = $split[1].Split(" ")

    $One = $split[0].Split(" ") | Where-Object {$_.ToCharArray().Count -eq 2}
    $Four = $split[0].Split(" ") | Where-Object {$_.ToCharArray().Count -eq 4}
    $Seven = $split[0].Split(" ") | Where-Object {$_.ToCharArray().Count -eq 3}
    $Eight = $split[0].Split(" ") | Where-Object {$_.ToCharArray().Count -eq 7}
    $notes = $split[0].Split(" ")

    $displayHash = @{
        1 = $One.ToCharArray() | Sort-Object
        2 = ($notes | Where-Object {$_.ToCharArray().Count -eq 5 -and ($_.ToCharArray() | ?{$One.ToCharArray() -contains $_}).Count -eq 1 -and ($_.ToCharArray() | ?{$Four.ToCharArray() -contains $_}).Count -eq 2 -and ($_.ToCharArray() | ?{$Seven.ToCharArray() -contains $_}).Count -eq 2}).ToCharArray() | Sort-Object
        3 = ($notes | Where-Object {$_.ToCharArray().Count -eq 5 -and ($_.ToCharArray() | ?{$One.ToCharArray() -contains $_}).Count -eq 2 -and ($_.ToCharArray() | ?{$Four.ToCharArray() -contains $_}).Count -eq 3 -and ($_.ToCharArray() | ?{$Seven.ToCharArray() -contains $_}).Count -eq 3}).ToCharArray() | Sort-Object
        4 = $Four.ToCharArray() | Sort-Object
        5 = ($notes | Where-Object {$_.ToCharArray().Count -eq 5 -and ($_.ToCharArray() | ?{$One.ToCharArray() -contains $_}).Count -eq 1 -and ($_.ToCharArray() | ?{$Four.ToCharArray() -contains $_}).Count -eq 3 -and ($_.ToCharArray() | ?{$Seven.ToCharArray() -contains $_}).Count -eq 2}).ToCharArray() | Sort-Object
        6 = ($notes | Where-Object {$_.ToCharArray().Count -eq 6 -and ($_.ToCharArray() | ?{$One.ToCharArray() -contains $_}).Count -eq 1 -and ($_.ToCharArray() | ?{$Four.ToCharArray() -contains $_}).Count -eq 3 -and ($_.ToCharArray() | ?{$Seven.ToCharArray() -contains $_}).Count -eq 2}).ToCharArray() | Sort-Object
        7 = $Seven.ToCharArray() | Sort-Object
        8 = $Eight.ToCharArray() | Sort-Object
        9 = ($notes | Where-Object {$_.ToCharArray().Count -eq 6 -and ($_.ToCharArray() | ?{$One.ToCharArray() -contains $_}).Count -eq 2 -and ($_.ToCharArray() | ?{$Four.ToCharArray() -contains $_}).Count -eq 4 -and ($_.ToCharArray() | ?{$Seven.ToCharArray() -contains $_}).Count -eq 3}).ToCharArray() | Sort-Object
        0 = ($notes | Where-Object {$_.ToCharArray().Count -eq 6 -and ($_.ToCharArray() | ?{$One.ToCharArray() -contains $_}).Count -eq 2 -and ($_.ToCharArray() | ?{$Four.ToCharArray() -contains $_}).Count -eq 3 -and ($_.ToCharArray() | ?{$Seven.ToCharArray() -contains $_}).Count -eq 3}).ToCharArray() | Sort-Object
    }

    $fourDigitSegment = @{
        1 = $numbers[0].ToCharArray() | Sort-Object
        2 = $numbers[1].ToCharArray() | Sort-Object
        3 = $numbers[2].ToCharArray() | Sort-Object
        4 = $numbers[3].ToCharArray() | Sort-Object
        Value = 0
    }

    for($i = 0; $i -lt 4; $i++)
    {
        foreach($key in $displayHash.Keys)
        {
            if([string]($fourDigitSegment[$i+1]-join'') -eq [string]($displayHash[$key]-join''))
            {
                $fourDigitSegment[$i+1] = $key
            }
        }
    }
    $fourDigitSegment.Value = [int]::Parse(@($fourDigitSegment[1],$fourDigitSegment[2],$fourDigitSegment[3],$fourDigitSegment[4])-join'')
    $fourDigitSegments += $fourDigitSegment
}
$sum = 0
$fourDigitSegments.Value | %{$sum += $_}
$sum
