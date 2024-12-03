#$puzzleInput = Get-Content $PSScriptRoot\example.txt
#$puzzleInput = Get-Content $PSScriptRoot\example2.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

$mulInstructions = ([Regex]::Matches($puzzleInput,"mul\((\d{1,3},\d{1,3})\)")).Groups.Where({$_.Name -eq 1})
$doInstructions = ([Regex]::Matches($puzzleInput,"do\(\)"))
$dontInstructions = ([Regex]::Matches($puzzleInput,"don't\(\)"))
$allInstructions = $mulInstructions+$doInstructions+$dontInstructions
$allInstructions = $allInstructions | Sort-Object Index

$sum = 0
$do = $true
foreach($i in $allInstructions){
    switch -regex ($i.Value)
    {
        '\d{1,3},\d{1,3}'
        {
            if($do)
            {
                $a, $b = $i.Value.Split(",")
                $sum += $a*$b
            }
        }
        'do\(\)'{$do = $true}
        "don't\(\)"{$do = $false}
    }
}
$sum