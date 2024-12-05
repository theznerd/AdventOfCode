#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

$rules = [System.Collections.Generic.List[int[]]]::new()
([Regex]::Matches($puzzleInput,"\d{1,2}\|\d{1,2}")) | ForEach-Object {$rules.Add([int[]]$_.Value.Split("|"))}

class InstructionValue : IComparable {
    [int]$val
    
    InstructionValue($in) {
        $this.val = [int]$in
    }

    [int]CompareTo($that)
    {
        # If rule exists with both, then left side must < right side index
        $leftSide, $rightSide = $script:rules.Where({$this.val -in $_ -and $that.val -in $_})[0] # there should only ever be one rule both numbers are in
        if($this.val -eq $leftSide){
            #this value should end up "less than"
            return -1;
        }
        elseif($this.val -eq $rightSide){
            #this value shoudl end up "greater than"
            return 1;
        }
        # If either number not in rules list, then return 0 (they're equivalent)
        return 0;
    }
}

class InstructionSet {
    $instructions = [System.Collections.Generic.List[InstructionValue]]::new()

    InstructionSet($in) {
        foreach($i in $in){
            $this.instructions.Add([InstructionValue]$i)
        }
    }
    
    [bool] TestInstruction() {
        $tempInstructions = [System.Collections.Generic.List[InstructionValue]]::new($this.instructions)
        $tempInstructions.Sort()
        if([System.Linq.Enumerable]::SequenceEqual($tempInstructions, $this.instructions)){
            return $true
        }
        else{
            return $false
        }
    }
}

$instructions = [System.Collections.Generic.List[InstructionSet]]::new()
([Regex]::Matches($puzzleInput,"(?:\d{1,2},)+\d{1,2}")) | ForEach-Object {$instructions.Add([InstructionSet]$_.Value.Split(","))}

$sum = 0
foreach($instruction in $instructions){
    if(!$instruction.TestInstruction()){
        $instruction.instructions.Sort() # Sort repairs all things
        $sum += $instruction.instructions[[Math]::floor($instruction.instructions.Count/2)].val
    }   
}
$sum