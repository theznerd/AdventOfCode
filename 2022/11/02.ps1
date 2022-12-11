$input = Get-Content $PSScriptRoot\input.txt -raw

class Item {
    [int]$originalValue
    [hashtable]$modulusValues
    UpdateModulusValues($operator, $value)
    {
        foreach($v in @($this.modulusValues.Keys))
        {
            if($value -eq "old"){
                switch($operator)
                {
                    "+" {
                        $this.modulusValues["$v"] = ($this.modulusValues["$v"] + $this.modulusValues["$v"]) % [int]$v
                        break
                    }
                    "-" {
                        $this.modulusValues["$v"] = ($this.modulusValues["$v"] - $this.modulusValues["$v"]) % [int]$v
                        break
                    }
                    "*" {
                        $this.modulusValues["$v"] = ($this.modulusValues["$v"] * $this.modulusValues["$v"]) % [int]$v
                        break
                    }
                }
            }
            else{
                switch($operator)
                {
                    "+" {
                        $this.modulusValues["$v"] = ($this.modulusValues["$v"] + ($value % [int]$v)) % [int]$v
                        break
                    }
                    "-" {
                        $this.modulusValues["$v"] = ($this.modulusValues["$v"] - ($value % [int]$v)) % [int]$v
                        break
                    }
                    "*" {
                        $this.modulusValues["$v"] = ($this.modulusValues["$v"] * ($value % [int]$v)) % [int]$v
                        break
                    }
                }
            }
        }
    }
}

class Monkey {
    [int]$id
    [System.Collections.Generic.Queue[[Item]]]$items = [System.Collections.Generic.Queue[[Item]]]@()
    
    [string]$operation
    [string]$value
    [Item]$heldItem
    [int]$totalInspections = 0
    [void]InspectItem()
    {
        $this.heldItem.UpdateModulusValues($this.operation, $this.value)
    }

    [int]$trueMonkey
    [int]$falseMonkey
    [int]$testModulus
    [void]TestItem()
    {
        if($this.heldItem.modulusValues["$($this.testModulus)"] -eq 0)
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
    
    $inspectTest = $operation.Replace("  Operation: new = old ","").Split(" ")
    $monkey.operation = $inspectTest[0]
    $monkey.value = $inspectTest[1]

    $monkey.testModulus = $test.Replace("  Test: divisible by ","")
    $monkey.falseMonkey = $falseMonkey.Replace("    If false: throw to monkey ","")
    $monkey.trueMonkey = $trueMonkey.Replace("    If true: throw to monkey ","")
    $monkies.Add($monkey)
}

## now we know what modulus tests we need to run
$primes = $monkies.testModulus
$baseHash = @{}
foreach($p in $primes)
{
    $baseHash["$p"] = 0
}

## build the list of items now
foreach($monkeyNote in $monkeyNotes)
{
    $monkeyId, $startingItems, $operation, $test, $trueMonkey, $falseMonkey = $monkeyNote -split "`r`n"
    $monkeyId = $monkeyId.Replace("Monkey ","").Replace(":","")
    $items = [int[]]@($startingItems.Replace("  Starting items: ","").Split(", "))
    foreach($i in $items)
    {
        $item = [Item]::new()
        $item.modulusValues = $baseHash.Clone()
        $item.originalValue = $i
        foreach($v in @($item.modulusValues.Keys))
        {
            $item.modulusValues["$v"] = $item.originalValue % [int]$v
        }
        $monkies[$monkeyId].items.Enqueue($item)
    }
}


## iterate the tests
$iterations = 10000
for($r = 0; $r -lt $iterations; $r++)
{
    if($r % 500 -eq 0)
    {
        Write-Output "$(($r/$iterations)*100)% Complete"
    }
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