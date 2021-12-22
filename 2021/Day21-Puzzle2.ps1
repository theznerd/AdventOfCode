$playerOneStartingPosition = 2
$playerTwoStartingPosition = 10

$possibleRollValues = @(
    ,@(3,1)
    ,@(4,3)
    ,@(5,6)
    ,@(6,7)
    ,@(7,6)
    ,@(8,3)
    ,@(9,1)
)

$playerOneScoreTable = @{ "s0p$playerOneStartingPosition" = 1 }
$playerOneWinTable = @{1=0;2=0} # we know that no one can win in rounds one or two

$playerTwoScoreTable = @{ "s0p$playerTwoStartingPosition" = 1 }
$playerTwoWinTable = @{1=0;2=0} # we know that no one can win in rounds one or two

######################################################################
# Let's have each player play every possible game to 21 on their own #
######################################################################
$turns = 1 # generation counter, necessary for number of turns to win
while($playerOneScoreTable.Count -gt 0)
{
    $tempScoreTable = $playerOneScoreTable.Clone() # we'll use this table to pull info about the parents
    $playerOneScoreTable.Clear() # we need a clean table to put the data in (all parents die, but they spawn some number of children)
    foreach($scoreKey in $tempScoreTable.Keys)
    {
        foreach($rollValue in $possibleRollValues)
        {
            $value = $rollValue[0] # face value of all three dice
            $count = $rollValue[1] # the number of times this happens in distribution (e.g. 3 can only happen one way, but 6 can happen 7 ways)

            $scoreKeyScore = [int]([Regex]::Match($scoreKey,"s(.*?)p").Groups[1].Value) # what is the current score we're looking at
            $scoreKeyPosition = [int]([Regex]::Match($scoreKey,"p(.*?)$").Groups[1].Value) # what is the current position we're looking at
        
            $newPosition = if(([int]$scoreKeyPosition+$value)%10 -eq 0){10}else{([int]$scoreKeyPosition+$value)%10} # let's move all the pawns from this position
            $newScore = $([int]$scoreKeyScore+$newPosition) # here's our new score
            if($newScore -ge 21)
            {
                $playerOneWinTable[$turns] += $count*$tempScoreTable[$scoreKey] # if we won, we mark which round we won it
            }
            else
            {
                $playerOneScoreTable["s$($newScore)p$newPosition"] += $count*$tempScoreTable[$scoreKey] # otherwise place the pawns back on the board at the correct spot
            }
        }
    }
    $turns++
}

$turns = 1 # reset the turn counter
while($playerTwoScoreTable.Count -gt 0)
{
    $tempScoreTable = $playerTwoScoreTable.Clone()
    $playerTwoScoreTable.Clear()
    foreach($scoreKey in $tempScoreTable.Keys)
    {
        foreach($rollValue in $possibleRollValues)
        {
            $value = $rollValue[0]
            $count = $rollValue[1]

            $scoreKeyScore = [int]([Regex]::Match($scoreKey,"s(.*?)p").Groups[1].Value)
            $scoreKeyPosition = [int]([Regex]::Match($scoreKey,"p(.*?)$").Groups[1].Value)
        
            $newPosition = if(([int]$scoreKeyPosition+$value)%10 -eq 0){10}else{([int]$scoreKeyPosition+$value)%10}
            if(($scoreKeyScore+$newPosition) -ge 21)
            {
                $playerTwoWinTable[$turns] += $count*$tempScoreTable[$scoreKey]
            }
            else
            {
                $playerTwoScoreTable["s$($scoreKeyScore+$newPosition)p$newPosition"] += $count*$tempScoreTable[$scoreKey]
            }
        }
    }
    $turns++
}

#############################################
# Now we calculate the number of total wins #
#############################################
$playerOneWinCount = 0
$product = 1
for($i = 1; $i -lt $playerOneWinTable.Keys.Count+1; $i++)
{
    $playerOneWinCount += $playerOneWinTable[$i] * $product # this is how many games we won this round
    $product *= 27 # by playing this round we generated 27 (3^3) times more universes
    $product -= $playerTwoWinTable[$i] # however in this round, player two would have won this many times, so take them out from the pile
}
#$playerOneWinCount

$playerTwoWinCount = 0
$product = 1
for($i = 1; $i -lt $playerTwoWinTable.Keys.Count+1; $i++)
{
    $product *= 27 # player one already generated 27 times more new realities
    $product -= $playerOneWinTable[$i] # but they won in a bunch of realities so we won't be playing against them
    $playerTwoWinCount += $playerTwoWinTable[$i] * $product # BUT player two won this many times this round
}
#$playerTwoWinCount
[Math]::Max($playerOneWinCount, $playerTwoWinCount)
