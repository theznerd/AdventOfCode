#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

$safeReports = 0
:report foreach($report in $puzzleInput)
{
    [Collections.Generic.List[int]]$r = $report.Split(" ")
    $growing = $r[1] -gt $r[0]
    for($i = 0; $i -lt ($r.Count - 1); $i++){
        if(-not((($growing -and $r[($i+1)] -gt $r[$i]) -or (!$growing -and $r[($i+1)] -lt $r[$i])) -and ([Math]::abs($r[($i+1)] - $r[$i]) -le 3)))
        {
            # HIT A FAILURE
            #Dampener
            $d1 = [Collections.Generic.List[int]]::new($r)
            $d2 = [Collections.Generic.List[int]]::new($r)
            $d3 = [Collections.Generic.List[int]]::new($r)
            if($i -gt 0){$d1.RemoveAt(($i-1))}
            $d2.RemoveAt(($i))
            $d3.RemoveAt(($i+1))

            $d1fail = if($i -eq 0){$true}else{$false}
            $d2fail = $d3fail = $false
            $growing = $d1[1] -gt $d1[0]
            if($i -gt 0){
                for($d = 0; $d -lt ($d1.Count - 1); $d++){
                    if(-not((($growing -and $d1[($d+1)] -gt $d1[$d]) -or (!$growing -and $d1[($d+1)] -lt $d1[$d])) -and ([Math]::abs($d1[($d+1)] - $d1[$d]) -le 3)))
                    {
                        $d1fail = $true
                        break
                    }
                }
            }
            if(!$d1fail){$safeReports++; continue report}
            $growing = $d2[1] -gt $d2[0]
            for($d = 0; $d -lt ($d2.Count - 1); $d++){
                if(-not((($growing -and $d2[($d+1)] -gt $d2[$d]) -or (!$growing -and $d2[($d+1)] -lt $d2[$d])) -and ([Math]::abs($d2[($d+1)] - $d2[$d]) -le 3)))
                {
                    $d2fail = $true
                    break
                }
            }
            if(!$d2fail){$safeReports++; continue report}
            $growing = $d3[1] -gt $d3[0]
            for($d = 0; $d -lt ($d3.Count - 1); $d++){
                if(-not((($growing -and $d3[($d+1)] -gt $d3[$d]) -or (!$growing -and $d3[($d+1)] -lt $d3[$d])) -and ([Math]::abs($d3[($d+1)] - $d3[$d]) -le 3)))
                {
                    $d3fail = $true
                    break
                }

            }
            if(!$d3fail){$safeReports++}
            continue report
        }
    }
    $safeReports++
}
$safeReports