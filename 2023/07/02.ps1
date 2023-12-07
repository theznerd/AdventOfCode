#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

class CamelHand : System.IComparable {
    static [hashtable]$possibleHands = @{
        1 =   @(1,1,1,1,1)
        2 =   @(2,1,1,1)
        2.1 = @(1,1,1,1)
        3 =   @(2,2,1)
        #3.1 = @(2,1,1) the better play with one joker is to make 3 of a kind in this case
        3.2 = @(2,1)
        4 =   @(3,1,1)
        4.1 = @(2,1,1)
        4.2 = @(1,1,1)
        5 =   @(3,2)
        5.1 = @(2,2)
        # 5.1 = @(3,1) the better play with one joker is to make 4 of a kind in this case
        6 =   @(4,1)
        6.1 = @(3,1)
        # 6.2 = @(3) the better play with two jokers is to make 5 of a kind in this case
        6.2 = @(2,1)
        6.3 = @(1,1)
        7 =   @(5)
        7.1 = @(4)
        7.2 = @(3)
        7.3 = @(2)
        7.4 = @(1)
        7.5 = @()
    }
    static [hashtable]$cvalue = @{
        "A" = 14
        "K" = 13
        "Q" = 12
        "J" = 0 # although J is joker, it is weakest for comparison
        "T" = 10
        "9" = 9
        "8" = 8
        "7" = 7
        "6" = 6
        "5" = 5
        "4" = 4
        "3" = 3
        "2" = 2
    }
    [string]$originalOrder
    [hashtable]$cardValues = @{}
    [int]$countJokers = 0
    [int]$bet
    [int]$score
    CamelHand ([string]$hand) {
        $this.originalOrder, $this.bet = $hand -split " "
        foreach($c in $this.originalOrder.ToCharArray()){
            if($c -eq "J"){$this.countJokers++}
            else{$this.cardValues[$c]++}
        }

        foreach($s in [CamelHand]::possibleHands.GetEnumerator())
        {
            if(-not (Compare-Object $s.Value @($this.cardValues.Values))){$this.score = [Math]::Floor($s.Name); break} 
        }
    }

    [int]CompareTo($rightHand){
        return [CamelHand]::CompareHands($this, $rightHand)
    }

    hidden static [int]CompareHands([CamelHand]$leftHand, [CamelHand]$rightHand){
        if($leftHand.score -gt $rightHand.score){return -1}
        elseif($leftHand.score -lt $rightHand.score){return 1}
        else{
            for($i = 0; $i -lt 5; $i++)
            {
                if([CamelHand]::cvalue["$($leftHand.originalOrder[$i])"] -gt [CamelHand]::cvalue["$($rightHand.originalOrder[$i])"]){
                    return -1
                }
                elseif([CamelHand]::cvalue["$($leftHand.originalOrder[$i])"] -lt [CamelHand]::cvalue["$($rightHand.originalOrder[$i])"]){
                    return 1
                }
            }
        }
        return 0;
    }
}

$hands = [System.Collections.Generic.List[CamelHand]]@()
foreach($hand in $puzzleInput)
{
    $hands.Add([CamelHand]::new($hand))
}
$hands.Sort()

$totalWinnings = 0
$w = 1
for($i = ($hands.Count - 1); $i -ge 0; $i--)
{
    $totalWinnings += ($hands[$i].bet * $w)
    $w++
}
$totalWinnings