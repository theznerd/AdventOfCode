#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

$ErrorActionPreference = 'Break'

class Problem {
    [long[]]$values
    [string]$operation
    [int]$operationIndex
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
$operations = [regex]::Matches($puzzleInput[-1], "\*|\+")
foreach($operation in $operations)
{
    $problem = [Problem]::new()
    $problem.operation = $operation.Value
    $problem.operationIndex = $operation.Index
    $problems.Add($problem)
}

for($problem = 0; $problem -lt $problems.Count; $problem++)
{
    $startIndex = $problems[$problem].operationIndex
    $endIndex = $problems[($problem + 1)].operationIndex - 2
    if($problem -eq $problems.Count - 1){$endIndex = $puzzleInput[0].Length - 1}

    for($column = $endIndex; $column -ge $startIndex; $column--)
    {
        $number = ""
        for($row = 0; $row -lt $puzzleInput.Count - 1; $row++)
        {
            $number += $puzzleInput[$row][$column]
        }
        $problems[$problem].values += [long]::Parse($number.Trim())
    }
}

[long]$sumResults = 0
foreach($problem in $problems)
{
    $result = $problem.Solve()
    $sumResults += $result
}
$sumResults