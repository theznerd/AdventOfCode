$playerOneStartingPosition = 2
$playerTwoStartingPosition = 10

$playerOneScore = 0
$playerOnePosition = $playerOneStartingPosition
$playerTwoScore = 0
$playerTwoPosition = $playerTwoStartingPosition

# deterministic die - x mod 100
# game board - x mod 10
$dieSize = 100
$gameBoard = 10

# starting die number
$i = 1

while($true)
{
    $roll1 = if($i % $dieSize -eq 0){100}else{$i % $dieSize}
    $roll2 = if(($i+1) % $dieSize -eq 0){100}else{($i+1) % $dieSize}
    $roll3 = if(($i+2) % $dieSize -eq 0){100}else{($i+2) % $dieSize}
    $playerOnePosition = $playerOnePosition + $roll1 + $roll2 + $roll3
    $playerOnePosition = if($playerOnePosition % $gameBoard -eq 0){10}else{$playerOnePosition % $gameBoard}
    $playerOneScore += $playerOnePosition
    $i = $i+3
    if($playerOneScore -ge 1000)
    {
        break
    }

    $roll1 = if($i % $dieSize -eq 0){100}else{$i % $dieSize}
    $roll2 = if(($i+1) % $dieSize -eq 0){100}else{($i+1) % $dieSize}
    $roll3 = if(($i+2) % $dieSize -eq 0){100}else{($i+2) % $dieSize}
    $playerTwoPosition = $playerTwoPosition + $roll1 + $roll2 + $roll3
    $playerTwoPosition = if($playerTwoPosition % $gameBoard -eq 0){10}else{$playerTwoPosition % $gameBoard}
    $playerTwoScore += $playerTwoPosition
    $i = $i+3
    if($playerTwoScore -ge 1000)
    {
        break
    }
    
}
Write-Host "Dice Rolls: $($i-1)"
Write-Host "Losing Score: $([Math]::Min($playerOneScore, $playerTwoScore))"
Write-Host "Puzzle Output: $(([Math]::Min($playerOneScore, $playerTwoScore))*($i-1))"
