$puzzleInput = Get-Content 'C:\Users\Nathan Ziehnert\OneDrive - Z-Nerd\Documents\AOC\2021\08\input.txt'

$sum = 0
foreach($segment in $puzzleInput)
{
    $split = ($segment -Split ' \| ')
    $numbers = $split[1].Split(" ")

    $notes = $split[0].Split(" ")
    $One = ($notes.Where({$_.ToCharArray().Count -eq 2})).ToCharArray() | Sort-Object
    $Four = ($notes.Where({$_.ToCharArray().Count -eq 4})).ToCharArray() | Sort-Object
    $Seven = ($notes.Where({$_.ToCharArray().Count -eq 3})).ToCharArray() | Sort-Object
    $Eight = ($notes.Where({$_.ToCharArray().Count -eq 7})).ToCharArray() | Sort-Object
    

    $displayHash = @{
        1 = $One
        2 = ($notes.Where({$ca = $_.ToCharArray(); ($ca.Count -eq 5 -and ($ca | ?{$One -contains $_}).Count -eq 1 -and ($ca | ?{$Four -contains $_}).Count -eq 2 -and ($ca | ?{$Seven -contains $_}).Count -eq 2)})).ToCharArray() | Sort-Object
        3 = ($notes.Where({$ca = $_.ToCharArray(); ($ca.Count -eq 5 -and ($ca | ?{$One -contains $_}).Count -eq 2 -and ($ca | ?{$Four -contains $_}).Count -eq 3 -and ($ca | ?{$Seven -contains $_}).Count -eq 3)})).ToCharArray() | Sort-Object
        4 = $Four
        5 = ($notes.Where({$ca = $_.ToCharArray(); ($ca.Count -eq 5 -and ($ca | ?{$One -contains $_}).Count -eq 1 -and ($ca | ?{$Four -contains $_}).Count -eq 3 -and ($ca | ?{$Seven -contains $_}).Count -eq 2)})).ToCharArray() | Sort-Object
        6 = ($notes.Where({$ca = $_.ToCharArray(); ($ca.Count -eq 6 -and ($ca | ?{$One -contains $_}).Count -eq 1 -and ($ca | ?{$Four -contains $_}).Count -eq 3 -and ($ca | ?{$Seven -contains $_}).Count -eq 2)})).ToCharArray() | Sort-Object
        7 = $Seven
        8 = $Eight
        9 = ($notes.Where({$ca = $_.ToCharArray(); ($ca.Count -eq 6 -and ($ca | ?{$One -contains $_}).Count -eq 2 -and ($ca | ?{$Four -contains $_}).Count -eq 4 -and ($ca | ?{$Seven -contains $_}).Count -eq 3)})).ToCharArray() | Sort-Object
        0 = ($notes.Where({$ca = $_.ToCharArray(); ($ca.Count -eq 6 -and ($ca | ?{$One -contains $_}).Count -eq 2 -and ($ca | ?{$Four -contains $_}).Count -eq 3 -and ($ca | ?{$Seven -contains $_}).Count -eq 3)})).ToCharArray() | Sort-Object
    }

    $fourDigitSegment = @{
        1 = $numbers[0].ToCharArray() | Sort-Object
        2 = $numbers[1].ToCharArray() | Sort-Object
        3 = $numbers[2].ToCharArray() | Sort-Object
        4 = $numbers[3].ToCharArray() | Sort-Object
    }

    for($i = 0; $i -lt 4; $i++)
    {
        foreach($key in $displayHash.Keys)
        {
            if([string]($fourDigitSegment[$i+1]-join'') -eq [string]($displayHash[$key]-join''))
            {
                $fourDigitSegment[$i+1] = $key
                break
            }
        }
    }
    $sum += [int]::Parse($fourDigitSegment[1..4]-join'')
}
$sum
