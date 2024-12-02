#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

$safeReports = 0
:report foreach($report in $puzzleInput)
{
    [int[]]$r = $report.Split(" ")
    $growing = $r[1] -gt $r[0]
    for($i = 0; $i -lt ($r.Count - 1); $i++){
        if(-not((($growing -and $r[($i+1)] -gt $r[$i]) -or (!$growing -and $r[($i+1)] -lt $r[$i])) -and ([Math]::abs($r[($i+1)] - $r[$i]) -le 3)))
        {
            continue report
        }
    }
    $safeReports++
}
$safeReports