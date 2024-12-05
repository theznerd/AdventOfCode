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

$instructions = [System.Collections.Generic.List[int[]]]::new()
([Regex]::Matches($puzzleInput,"(?:\d{1,2},)+\d{1,2}")).Value | ForEach-Object {$instructions.Add([int[]]$_.Split(","))}

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

$sum = 0
foreach($instruction in $instructions){
    if(Test-Rule $instruction){
        $sum += $instruction[([Math]::floor($instruction.count / 2))]
    }
}
$sum