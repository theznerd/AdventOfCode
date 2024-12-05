#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

$rules = @{}
([Regex]::Matches($puzzleInput,"\d{1,2}\|\d{1,2}")) | ForEach-Object {
    [int[]]$ruleParts = $_.Value.Split("|")
    if (-not $rules.ContainsKey($ruleParts[0])) {
        $rules[$ruleParts[0]] = @()
    }
    $rules[$ruleParts[0]] += ,$ruleParts
}

$instructions = @()
([Regex]::Matches($puzzleInput,"(?:\d{1,2},)+\d{1,2}")).Value | ForEach-Object {
    $instructions += ,[System.Collections.Generic.List[int]]::New([int[]]$_.Split(","))
}

function Test-Rule($instruction) {
    foreach($page in $instruction){
        foreach($rule in $rules[$page]){
            if($instruction.IndexOf($rule[1]) -ge 0 -and $instruction.IndexOf($rule[0]) -gt $instruction.IndexOf($rule[1])){
                return $false
            }
        }
    }
    return $true
}

function Repair-Instruction($instruction) {
    :page for($i = 1; $i -lt $instruction.Count; $i++){
        $rulesToTest = if($rules[($instruction[$i])]){$rules[($instruction[$i])]| ForEach-Object {$_[1]}}else{@()}
        for($x = 0; $x -lt $i; $x++){
            if($instruction[$x] -in $rulesToTest){
                $item = $instruction[$i]
                $instruction.RemoveAt($i)
                $instruction.Insert($x, $item)
                continue page
            }
        }
    }
}

$sum = 0
foreach($instruction in $instructions){
    if(!(Test-Rule $instruction)){
        Repair-Instruction $instruction
        $sum += $instruction[([Math]::floor($instruction.count / 2))]
    }
}
$sum