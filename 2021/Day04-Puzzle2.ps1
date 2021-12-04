$puzzleInput = Get-Content 'C:\Users\Nathan Ziehnert\OneDrive - Z-Nerd\Documents\AOC\2021\04\Day4Input.txt'

$calledNumbers = $puzzleInput[0].Split(",")
$bingoBoardList = $puzzleInput[2..$puzzleInput.Count]
$bingoBoards = @()

for($i = 0; $i -lt $bingoBoardList.Count; $i += 6)
{
    $boardArray = New-Object 'int[,]' 5,5
    for($j = 0; $j -lt 5; $j++)
    {
        $boardArray[$j,0] = [Convert]::ToInt32($bingoBoardList[$i+$j].Substring(0,3))
        $boardArray[$j,1] = [Convert]::ToInt32($bingoBoardList[$i+$j].Substring(3,3))
        $boardArray[$j,2] = [Convert]::ToInt32($bingoBoardList[$i+$j].Substring(6,3))
        $boardArray[$j,3] = [Convert]::ToInt32($bingoBoardList[$i+$j].Substring(9,3))
        $boardArray[$j,4] = [Convert]::ToInt32($bingoBoardList[$i+$j].Substring(12,2))
    }
    $bingoBoards += [pscustomobject]@{Board = $boardArray; CalledNumbers = @(); WinningNumber = -1; Winner = $false}
}

$orderedWinners = @()
foreach($number in $calledNumbers)
{
    foreach($board in $bingoBoards)
    {
        if(!$board.Winner)
        {
            if($number -in $board.Board)
            {
                $board.CalledNumbers += $number
            }

            # Check the board for a win
            for($i = 0; $i -lt 5; $i++)
            {
                if(-not @(@($board.Board[$i,0], $board.Board[$i,1], $board.Board[$i,2], $board.Board[$i,3], $board.Board[$i,4]) | where {$board.CalledNumbers -notcontains $_}).Count)
                {
                    $orderedWinners += $board
                    $board.WinningNumber = $number
                    $board.Winner = $true
                }
                if(-not @(@($board.Board[0,$i], $board.Board[1,$i], $board.Board[2,$i], $board.Board[3,$i], $board.Board[4,$i]) | where {$board.CalledNumbers -notcontains $_}).Count)
                {
                    $orderedWinners += $board
                    $board.WinningNumber = $number
                    $board.Winner = $true
                }
            }
        }
    }
}

$uncalledNumbers = $orderedWinners[-1].Board | Where-Object {$_ -notin $orderedWinners[-1].CalledNumbers}
$sum = 0
$uncalledNumbers | foreach{$sum += $_}

$sum * $orderedWinners[-1].WinningNumber
