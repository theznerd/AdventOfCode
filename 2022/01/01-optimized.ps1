$puzzleInput = (Get-Content $PSScriptRoot\input.txt -Raw) -split '(?:\r?\n){2,}' 
$elves | ForEach-Object {($_.Split("`r`n") | Measure-Object -Sum).Sum} | Sort-Object -Descending -Top 1