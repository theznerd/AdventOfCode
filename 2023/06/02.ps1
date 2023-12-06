#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

$raceTime = [int64](([regex]'\d+').Matches($puzzleInput[0]).Value -join '')
$winningDistance = [int64](([regex]'\d+').Matches($puzzleInput[1]).Value -join '')

# This is bruteforce AF...
# Surely there is a better way
# Not sure how this works if the race time is even... probably some maths to work out there
$winMin = 0
:outer for($i = 1; $i -lt $raceTime; $i+=1000)
{
    if($i*($raceTime-$i) -gt $winningDistance){
        for($n = $i; $n -gt 0; $n--){
            if($n*($raceTime-$n) -le $winningDistance){$winMin = ($n+1); break outer;}
        }
    }
}
($raceTime - (2*$winMin) + 1)