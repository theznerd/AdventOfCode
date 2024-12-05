#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

$rules = @{}
([Regex]::Matches($puzzleInput,"\d{1,2}\|\d{1,2}")) | ForEach-Object {
    [int[]]$ruleParts = $_.Value.Split("|")
    $rules[$ruleParts[0]] += ,$ruleParts
}

$instructions = @()
([Regex]::Matches($puzzleInput,"(?:\d{1,2},)+\d{1,2}")).Value | ForEach-Object {
    $instructions += ,[System.Collections.Generic.List[int]]::New([int[]]$_.Split(","))
}

$sum = 0
:instruction foreach($instruction in $instructions){
    for($i = 1; $i -lt $instruction.Count; $i++){
        $rulesToTest = if($rules[($instruction[$i])]){$rules[($instruction[$i])]| ForEach-Object {$_[1]}}else{@()}
        for($x = 0; $x -lt $i; $x++){
            if($instruction[$x] -in $rulesToTest){
                continue instruction
            }
        }
    }
    $sum += $instruction[([Math]::floor($instruction.count / 2))]
}
$sum