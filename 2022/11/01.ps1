$input = Get-Content $PSScriptRoot\input.txt -raw

class Monkey {
    [int]$id
    [System.Collections.Generic.Queue[int]]$items
    
    [string]$operation
    [string]$value
    [int]$heldItem
    [int]$totalInspections = 0
    [void]InspectItem()
    {
        $newValue = $this.value
        if($this.value -eq "old"){$newValue = $this.heldItem}
        switch($this.operation)
        {
            "+" {$this.heldItem += $newValue; break}
            "-" {$this.heldItem -= $newValue; break}
            "*" {$this.heldItem *= $newValue; break}
            "/" {$this.heldItem /= $newValue; break}
        }
        $this.heldItem = [Math]::Floor($this.heldItem / 3) ## my worry divides by three
    }

    [int]$trueMonkey
    [int]$falseMonkey
    [int]$testModulus
    [void]TestItem()
    {
        if($this.heldItem % $this.testModulus -eq 0)
        {
            $script:Monkies[$this.trueMonkey].items.Enqueue($this.heldItem)
        }
        else
        {
            $script:Monkies[$this.falseMonkey].items.Enqueue($this.heldItem)
        }
        $this.heldItem = $null
    }
}

$script:Monkies = [System.Collections.Generic.List[Monkey]]@()

$monkeyNotes = $input -split "`r`n`r`n"
foreach($monkeyNote in $monkeyNotes)
{
    $monkeyId, $startingItems, $operation, $test, $trueMonkey, $falseMonkey = $monkeyNote -split "`r`n"
    $monkey = [Monkey]::new()
    $monkey.id = $monkeyId.Replace("Monkey ","").Replace(":","")
    $monkey.items = [System.Collections.Generic.Queue[int]]@($startingItems.Replace("  Starting items: ","").Split(", "))
    
    $inspectTest = $operation.Replace("  Operation: new = old ","").Split(" ")
    $monkey.operation = $inspectTest[0]
    $monkey.value = $inspectTest[1]

    $monkey.testModulus = $test.Replace("  Test: divisible by ","")
    $monkey.falseMonkey = $falseMonkey.Replace("    If false: throw to monkey ","")
    $monkey.trueMonkey = $trueMonkey.Replace("    If true: throw to monkey ","")
    $monkies.Add($monkey)
}

for($r = 0; $r -lt 20; $r++)
{
    foreach($m in $monkies)
    {
        $heldItems = $m.items.Count
        for($i = 0; $i -lt $heldItems; $i++)
        {
            $m.totalInspections++
            $m.heldItem = $m.items.Dequeue()
            $m.InspectItem()
            $m.TestItem()
        }
    }
}

$inspections = ($monkies | Sort-Object totalInspections -Descending | Select-Object -First 2).totalInspections
$inspections[0] * $inspections[1]