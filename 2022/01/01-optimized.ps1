(Get-Content $PSScriptRoot\input.txt -Raw) -split '(?:\r?\n){2,}' | ForEach-Object {($_.Split("`r`n") | Measure-Object -Sum).Sum} | Sort-Object -Descending -Top 1