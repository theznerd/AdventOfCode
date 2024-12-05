#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

$rules = @{}
([Regex]::Matches($puzzleInput,"\d{1,2}\|\d{1,2}")) | ForEach-Object {
    [int[]]$ruleParts = $_.Value.Split("|")
    if(!$rules.ContainsKey($ruleParts[0])){$rules[$ruleparts[0]] = @()}
    $rules[$ruleParts[0]] += $ruleParts[1]
}

$instructions = @()
([Regex]::Matches($puzzleInput,"(?:\d{1,2},)+\d{1,2}")).Value | ForEach-Object {
    $instructions += ,[System.Collections.Generic.List[int]]::New([int[]]$_.Split(","))
}

$sum = 0
foreach($instruction in $instructions){
    $repaired = $false
    :page for($i = 1; $i -lt $instruction.Count; $i++){
        for($x = 0; $x -lt $i; $x++){
            if($instruction[$x] -in $rules[($instruction[$i])]){
                $item = $instruction[$i]
                $instruction.RemoveAt($i)
                $instruction.Insert($x, $item)
                $repaired = $true
                continue page
            }
        }
    }
    if($repaired){
        $sum += $instruction[([Math]::floor($instruction.count / 2))]
    }
}
$sum