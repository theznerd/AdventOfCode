#$puzzleInput = Get-Content $PSScriptRoot\example.txt
$puzzleInput = Get-Content $PSScriptRoot\input.txt

$instructions, $null, $map = $puzzleInput -split "\r\n"

function Get-GCD {
    param (
        [int64]$a,
        [int64]$b
    )
    while ($b -ne 0) {
        $temp = $b
        $b = $a % $b
        $a = $temp
    }
    return $a
}

function Get-LCM {
    param (
        [int64]$a,
        [int64]$b
    )
    return [Math]::Abs($a * $b) / (Get-GCD $a $b)
}

function Get-LCMForArray {
    param ([int64[]]$numbers)
    $lcm = 1
    foreach ($n in $numbers) {
        $lcm = Get-LCM $lcm $n
    }
    return $lcm
}

enum direction {L;R}
$maps = @{}
foreach($m in $map)
{
    $name, $left, $right = ([regex]'[A-Z]{3}').Matches($m).Value
    $maps.Add($name, @($left,$right))
}

## Working through my example data
# AAA = 19667 to ZZZ
  # AAA -> MRC, BFN
  # ZZZ -> BFN, MRC
# JTA = 16897 to NVZ
  # JTA -> TKF, RXS
  # NVZ -> RXS, TKF
# TSA = 16343 to BSZ
  # TSA -> DJG, MFF
  # BSZ -> MFF, DJG
# BLA = 21883 to KRZ
  # BLA -> XPM, CFT
  # KRZ -> CFT, XPM
# QXA = 13019 to SGZ
  # QXA -> GBB, VXV
  # SGZ -> VXV, GBB
# NBA = 20221 to VKZ
  # NBA -> VPP, GCL
  # VKZ -> GCL, VPP
$cLocs = @{}
foreach($s in $maps.Keys.Where({$_.EndsWith("A")})){$cLocs.Add($s, 0)}
$aLocs = @($cLocs.Keys)
foreach($loc in $aLocs)
{
    $step = 0
    $cLoc = $loc
    do{
        $currentDirection = $instructions[($step % $instructions.Length)]
        $cLoc = $maps[$cLoc][[int]([direction]::$currentDirection)]
        $step++
    }until($cLoc.EndsWith("Z"))
    $cLocs[$loc] = $step
}
Get-LCMForArray $cLocs.Values