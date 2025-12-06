#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

class Problem {
    [long[]]$values
    [string]$operation
    [long]Solve(){
        switch($this.operation)
        {
            "+" { return $this.values | Measure-Object -Sum | Select-Object -ExpandProperty Sum }
            "*" { return $this.values | Foreach-Object -Begin {$p = 1} -Process {$p *= $_} -End {$p} }
        }
        return -1
    }
}

$problems = [Collections.Generic.List[Problem]]::new()
for($row = 0; $row -lt $puzzleInput.Count - 1; $row++)
{
    $values = $puzzleInput[$row].Trim() -split "\s+"
    for($i = 0; $i -lt $values.Count; $i++)
    {
        if($row -eq 0){$problems.Add([Problem]::new())}
        $problems[$i].values += [long]$values[$i]
    }
}
$operations = $puzzleInput[$puzzleInput.Count - 1].Trim() -split "\s+"
for($i = 0; $i -lt $operations.Count; $i++)
{
    $problems[$i].operation = $operations[$i]
}

[long]$sumResults = 0
foreach($problem in $problems)
{
    $result = $problem.Solve()
    $sumResults += $result
}
$sumResults