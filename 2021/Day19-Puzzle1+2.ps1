## Holy balls this puzzle sucked.
## There are so many extraneous properties and lines
## of code in here... maybe someday I'll want to look
## at this again, but right now I never want to see this
## code again. Many efficiencies to be gained... pathfinding
## before I build $OverlappingScannerTranslations would be a
## start.
$puzzleInput = Get-Content 'C:\Users\Nathan Ziehnert\OneDrive - Z-Nerd\Documents\AOC\2021\19\input.txt'
$puzzleInput = $puzzleInput | ? {![string]::IsNullOrWhiteSpace($_)}

# radians table
$rt = @{
     "0"   = 0
     "90"  = ([Math]::PI/180)*90
     "180" = [Math]::PI
     "270" = ([Math]::PI/180)*270
}

# [System.Numerics.Quaternion]::CreateFromYawPitchRoll()
#   Yaw = Y-Axis
#   Pitch = X-Axis
#   Roll = Z-Axis
$possibleQuaternions = @(
    [System.Numerics.Quaternion]::CreateFromYawPitchRoll($rt["0"],    $rt["0"],   $rt["0"]) # exclude no rotation
    [System.Numerics.Quaternion]::CreateFromYawPitchRoll($rt["0"],    $rt["0"],   $rt["90"])
    [System.Numerics.Quaternion]::CreateFromYawPitchRoll($rt["0"],    $rt["0"],   $rt["180"])
    [System.Numerics.Quaternion]::CreateFromYawPitchRoll($rt["0"],    $rt["0"],   $rt["270"])
    [System.Numerics.Quaternion]::CreateFromYawPitchRoll($rt["0"],    $rt["90"],  $rt["0"])
    [System.Numerics.Quaternion]::CreateFromYawPitchRoll($rt["0"],    $rt["90"],  $rt["90"])
    [System.Numerics.Quaternion]::CreateFromYawPitchRoll($rt["0"],    $rt["90"],  $rt["180"])
    [System.Numerics.Quaternion]::CreateFromYawPitchRoll($rt["0"],    $rt["90"],  $rt["270"])
    [System.Numerics.Quaternion]::CreateFromYawPitchRoll($rt["0"],    $rt["180"], $rt["0"])
    [System.Numerics.Quaternion]::CreateFromYawPitchRoll($rt["0"],    $rt["180"], $rt["90"])
    [System.Numerics.Quaternion]::CreateFromYawPitchRoll($rt["0"],    $rt["180"], $rt["180"])
    [System.Numerics.Quaternion]::CreateFromYawPitchRoll($rt["0"],    $rt["180"], $rt["270"])
    [System.Numerics.Quaternion]::CreateFromYawPitchRoll($rt["0"],    $rt["270"], $rt["0"])
    [System.Numerics.Quaternion]::CreateFromYawPitchRoll($rt["0"],    $rt["270"], $rt["90"])
    [System.Numerics.Quaternion]::CreateFromYawPitchRoll($rt["0"],    $rt["270"], $rt["180"])
    [System.Numerics.Quaternion]::CreateFromYawPitchRoll($rt["0"],    $rt["270"], $rt["270"])
    [System.Numerics.Quaternion]::CreateFromYawPitchRoll($rt["90"],   $rt["0"],   $rt["0"])
    [System.Numerics.Quaternion]::CreateFromYawPitchRoll($rt["90"],   $rt["0"],   $rt["90"])
    [System.Numerics.Quaternion]::CreateFromYawPitchRoll($rt["90"],   $rt["0"],   $rt["180"])
    [System.Numerics.Quaternion]::CreateFromYawPitchRoll($rt["90"],   $rt["0"],   $rt["270"])
    [System.Numerics.Quaternion]::CreateFromYawPitchRoll($rt["270"],  $rt["0"],   $rt["0"])
    [System.Numerics.Quaternion]::CreateFromYawPitchRoll($rt["270"],  $rt["0"],   $rt["90"])
    [System.Numerics.Quaternion]::CreateFromYawPitchRoll($rt["270"],  $rt["0"],   $rt["180"])
    [System.Numerics.Quaternion]::CreateFromYawPitchRoll($rt["270"],  $rt["0"],   $rt["270"])
)

class OverlappingQuadrilateral
{
    [int]$OverlappingScannerId
    [int]$BeaconId1
    [int]$BeaconId2
    [int]$BeaconId3
    [int]$BeaconId4
    [int]$OverlappingBeaconId1
    [int]$OverlappingBeaconId2
    [int]$OverlappingBeaconId3
    [int]$OverlappingBeaconId4
}

class Scanner 
{
    [int]$Id
    [System.Numerics.Vector3]$Coordinates
    [Beacon[]]$Beacons
    [pscustomobject[]]$BeaconDistances
    [int[]]$OverlappingScanners
    [int]$OverlappingScannerCount = 0
    $OverlappingQuadrilaterals = @{}
    [pscustomobject[]]$OverlappingScannerTranslations
    [bool]$IsMatched = $false
    [bool]$IsMoved = $false
    
    [int]$MatchedScannerId
    [System.Numerics.Quaternion]$Transform
    [System.Numerics.Vector3]$Translate
}

class Beacon
{
    [string]$Id
    [System.Numerics.Vector3]$Coordinates
}

function Get-RotatedPoint($point, $quaternion)
{
    $newPoint = [System.Numerics.Vector3]::Transform($point, $quaternion)
    $newPoint.X = [Math]::Round($newPoint.X)
    $newPoint.Y = [Math]::Round($newPoint.Y)
    $newPoint.Z = [Math]::Round($newPoint.Z)
    return $newPoint
}

function New-OverlappingQuadrilaterals($primaryId, $matchingDistancesPrimary, $secondaryId, $matchingDistancesSecondary)
{
    # Match beacon points
    $beaconIdMap = @{}
    $primaryLeftBeaconIds = $matchingDistancesPrimary.LeftBeacon | select -Unique
    foreach($beaconId in $primaryLeftBeaconIds)
    {
        if(!$beaconIdMap.ContainsKey($beaconId))
        {
            $primaryCompare = $matchingDistancesPrimary.Where({$_.LeftBeacon -eq $beaconId})
            $secondaryCompare = $matchingDistancesSecondary.Where({$_.Distance -in $primaryCompare.Distance})
            $matchingBeacon = ($secondaryCompare.LeftBeacon | group | sort Count -Descending)[0].Name
            $beaconIdMap.Add($beaconId,$matchingBeacon)
            foreach($beacon in $primaryCompare)
            {
                if(!$beaconIdMap.COntainsKey($beacon.RightBeacon))
                {
                    $secondaryBeaconId = $beaconIdMap[$beacon.LeftBeacon]
                    $rightMatchingBeacon = $secondaryCompare.Where({$_.LeftBeacon -eq $secondaryBeaconId -and $_.Distance -eq $beacon.Distance}).RightBeacon
                    $beaconIdMap.Add($beacon.RightBeacon,$rightMatchingBeacon)
                }
            }
        }
    }

    $quadrilateralPrimary = [OverlappingQuadrilateral]::new()
    $quadrilateralPrimary.OverlappingScannerId = $secondaryId

    $quadrilateralSecondary = [OverlappingQuadrilateral]::new()
    $quadrilateralSecondary.OverlappingScannerId = $primaryId

    for($i = 1; $i -le 4; $i++)
    {
        $quadrilateralPrimary."BeaconId$i" = $matchingDistancesPrimary.Where({$_.LeftBeacon -eq $primaryLeftBeaconIds[$i]})[0].LeftBeacon
        $quadrilateralPrimary."OverlappingBeaconId$i" = $beaconIdMap["$($quadrilateralPrimary."BeaconId$i")"]
        $quadrilateralSecondary."BeaconId$i" = $beaconIdMap["$($quadrilateralPrimary."BeaconId$i")"]
        $quadrilateralSecondary."OverlappingBeaconId$i" = $quadrilateralPrimary."BeaconId$i"
    }

    return @($quadrilateralPrimary, $quadrilateralSecondary)
}

function Get-MatchingScannerTranslation([Scanner]$masterScanner, [Scanner]$scannerToMatch)
{
    $masterBeacon1 = $masterScanner.Beacons.Where({$_.Id -eq $masterScanner.OverlappingQuadrilaterals[$scannerToMatch.Id].BeaconId1})
    $masterBeacon2 = $masterScanner.Beacons.Where({$_.Id -eq $masterScanner.OverlappingQuadrilaterals[$scannerToMatch.Id].BeaconId2})
    $masterBeacon3 = $masterScanner.Beacons.Where({$_.Id -eq $masterScanner.OverlappingQuadrilaterals[$scannerToMatch.Id].BeaconId3})
    $masterBeacon4 = $masterScanner.Beacons.Where({$_.Id -eq $masterScanner.OverlappingQuadrilaterals[$scannerToMatch.Id].BeaconId4})
    $matchBeacon1 = $scannerToMatch.Beacons.Where({$_.Id -eq $masterScanner.OverlappingQuadrilaterals[$scannerToMatch.Id].OverlappingBeaconId1})
    $matchBeacon2 = $scannerToMatch.Beacons.Where({$_.Id -eq $masterScanner.OverlappingQuadrilaterals[$scannerToMatch.Id].OverlappingBeaconId2})
    $matchBeacon3 = $scannerToMatch.Beacons.Where({$_.Id -eq $masterScanner.OverlappingQuadrilaterals[$scannerToMatch.Id].OverlappingBeaconId3})
    $matchBeacon4 = $scannerToMatch.Beacons.Where({$_.Id -eq $masterScanner.OverlappingQuadrilaterals[$scannerToMatch.Id].OverlappingBeaconId4})

    # Test to see if we even need to rotate
    $translateVector = [System.Numerics.Vector3]::Subtract($masterBeacon1.Coordinates, $matchBeacon1.Coordinates)
    # check remaining three points of quadrilateral
    if(
             [System.Numerics.Vector3]::Add($matchBeacon2.Coordinates,$translateVector) -eq $masterBeacon2.Coordinates `
        -and [System.Numerics.Vector3]::Add($matchBeacon3.Coordinates,$translateVector) -eq $masterBeacon3.Coordinates `
        -and [System.Numerics.Vector3]::Add($matchBeacon4.Coordinates,$translateVector) -eq $masterBeacon4.Coordinates)
    {
        $q = $possibleQuaternions[0]
        return @($q, $translateVector)
    }
    foreach($q in $possibleQuaternions)
    {
        # rotate all 4 points on $q
        $newMatchBeacon1 = Get-RotatedPoint $matchBeacon1.Coordinates $q
        $newMatchBeacon2 = Get-RotatedPoint $matchBeacon2.Coordinates $q
        $newMatchBeacon3 = Get-RotatedPoint $matchBeacon3.Coordinates $q
        $newMatchBeacon4 = Get-RotatedPoint $matchBeacon4.Coordinates $q
        
        $translateVector = [System.Numerics.Vector3]::Subtract($masterBeacon1.Coordinates, $newMatchBeacon1)
        # check remaining three points of quadrilateral
        if(
                 [System.Numerics.Vector3]::Add($newMatchBeacon2,$translateVector) -eq $masterBeacon2.Coordinates `
            -and [System.Numerics.Vector3]::Add($newMatchBeacon3,$translateVector) -eq $masterBeacon3.Coordinates `
            -and [System.Numerics.Vector3]::Add($newMatchBeacon4,$translateVector) -eq $masterBeacon4.Coordinates)
        {
            break
        }
    }
    return @($q, $translateVector)
}

# Build Scanner and Beacon Objects
$scannerArray = @()
foreach($line in $puzzleInput)
{
    if($line -match "--- scanner")
    {
        $currentScanner = [Scanner]::new()
        $currentScanner.Id = [int]($line.Substring($line.IndexOf("r")+2).Replace(" ---",""))
        $currentScanner.Coordinates = [System.Numerics.Vector3]::new(0,0,0)
        $beaconID = 0
        $scannerArray += $currentScanner
    }
    else
    {
        [int]$x,[int]$y,[int]$z = $line.Split(",")
        $beacon = [Beacon]::new()
        $beacon.Id = $beaconID
        $beacon.Coordinates = [System.Numerics.Vector3]::new($x,$y,$z)
        $currentScanner.Beacons += $beacon
        $beaconID++
    }
}

# Calculate beacon distances
foreach($scanner in $scannerArray)
{
    foreach($beacon in $scanner.Beacons)
    {
        foreach($secondBeacon in $scanner.Beacons)
        {
            if($secondBeacon -ne $beacon)
            {
                $scanner.BeaconDistances += [pscustomobject]@{
                    LeftBeacon = $beacon.Id
                    RightBeacon = $secondBeacon.Id
                    Distance = [Math]::Round([System.Numerics.Vector3]::Distance($beacon.Coordinates, $secondBeacon.Coordinates),4)
                }
            }
        }
    }
}

# Find overlapping scanners
foreach($scanner in $scannerArray)
{
    foreach($secondScanner in $scannerArray)
    {
        if($scanner -ne $secondScanner)
        {
            $matchingDistances = $scanner.BeaconDistances.Distance.Where({$secondScanner.BeaconDistances.Distance -contains $_})
            $matchingPoints =  $scanner.BeaconDistances.Where({$_.Distance -in $matchingDistances}).LeftBeacon
            $matchingPoints += $scanner.BeaconDistances.Where({$_.Distance -in $matchingDistances}).RightBeacon
            $matchingPoints =  $matchingPoints | select -Unique
            if($matchingPoints.Count -ge 12)
            {
                $scanner.OverlappingScanners += $secondScanner.Id
                $matchingQuadrilaterals = New-OverlappingQuadrilaterals $scanner.Id ($scanner.BeaconDistances.Where({$_.Distance -in $matchingDistances})) $secondScanner.Id ($secondScanner.BeaconDistances.Where({$_.Distance -in $matchingDistances}))
                if(!$scanner.OverlappingQuadrilaterals.ContainsKey($secondScanner.Id))
                {
                    $scanner.OverlappingQuadrilaterals.Add($secondScanner.Id, $matchingQuadrilaterals[0])
                }
                if(!$secondScanner.OverlappingQuadrilaterals.ContainsKey($scanner.Id))
                {
                    $secondScanner.OverlappingQuadrilaterals.Add($scanner.Id, $matchingQuadrilaterals[1])
                }
                $scanner.OverlappingScannerCount++
            }
        }
    }
}

# Rotate and translate Scanners/Beacons
#$masterScanner = ($scannerArray | Sort-Object OverlappingScannerCount)[-1] ## this scanner has the most overlapping scanners
$masterScanner = $scannerArray[0]
$masterScanner.IsMatched = $true
$masterScannerId = $masterScanner.Id

# Match the scanners
foreach($scanner in $scannerArray)
{
    if(!$scanner.IsMatched)
    {
        if($scanner.OverlappingScanners -contains $masterScannerId)
        {
            #$scanner.MatchedScannerId = $masterScannerId
            $translation = Get-MatchingScannerTranslation $masterScanner $scanner
            $scanner.OverlappingScannerTranslations += [pscustomobject]@{
                OverlappingScannerId = $masterScannerId
                Transform = $translation[0]
                Translate = $translation[1]
            }
            #$scanner.Transform,$scanner.Translate = $translation
            $scanner.IsMatched = $true
        }
        else
        {
            foreach($myMasterScanner in $scanner.OverlappingScanners)
            {
                #$myMasterScanner = $scanner.OverlappingScanners[0]
                #$scanner.MatchedScannerId = $myMasterScanner
                $translation = Get-MatchingScannerTranslation $scannerArray.Where({$_.Id -eq $myMasterScanner})[0] $scanner
                $scanner.OverlappingScannerTranslations += [pscustomobject]@{
                    OverlappingScannerId = $myMasterScanner
                    Transform = $translation[0]
                    Translate = $translation[1]
                }
                #$scanner.Transform,$scanner.Translate = $translation
                $scanner.IsMatched = $true
            }
        }
    }
}

# Translate/Transform the Scanners
function Get-StepsToMaster($scanner, $previousSteps = @())
{
    ## could use a pathfinding algorithm but really
    ## we're gonna bruteforce this because I'm tired
    ## of working out bugs in Day 19
    $previousSteps += $scanner.Id
    $steps = @()
    if($scanner.OverlappingScanners -contains 0)
    {
        return @(0)
    }
    foreach($matchingScannerId in $scanner.OverlappingScanners.Where({$_ -notin $previousSteps}))
    {
        $newSteps = @($scanner.Id)
        $newSteps += $matchingScannerId
        if($matchingScannerId -ne 0)
        {
            $newSteps += Get-StepsToMaster $scannerArray[$matchingScannerId] $previousSteps
        }
        if($newSteps[-1] -eq 0)
        {
            # Valid path
            if($steps.Count -eq 0 -or $newSteps.Count -lt $steps.Count)
            {
                $steps = $newSteps
            }
        }
    }

    ## this is ugly but again, I'm freakin tired
    $finalSteps = @()
    foreach($step in $steps)
    {
        if($step -notin $finalSteps)
        {
            $finalSteps += $step
        }
    }
    return $finalSteps
}


function Get-PathToMasterScanner($scanner)
{
    $steps = Get-StepsToMaster($scanner)
    $translationSteps = @()
    
    if($scanner.Id -eq 0)
    {
        return $translationSteps
    }
    if($steps[0] -eq 0)
    {
        $pathToZero = $scanner.OverlappingScannerTranslations.Where({$_.OverlappingScannerId -eq 0})
        $translationSteps += $pathToZero.Transform
        $translationSteps += $pathToZero.Translate
    }
    else
    {
        for($i = 0; $i -lt $steps.Count-1; $i++)
        {
            if($steps[$i] -eq 0)
            {
                $pathToZero = $scannerArray[$steps[($i-1)]].OverlappingScannerTranslations.Where({$_.OverlappingScannerId -eq $steps[$i]})
                $translationSteps += $pathToZero.Transform
                $translationSteps += $pathToZero.Translate
            }
            else
            {
                $nextInPath = $scannerArray[$steps[$i]].OverlappingScannerTranslations.Where({$_.OverlappingScannerId -eq $steps[($i+1)]})
                $translationSteps += $nextInPath.Transform
                $translationSteps += $nextInPath.Translate
            }
        }
    }
    return $translationSteps
}

function Invoke-LineItUpBaby($scanner, $translationSteps)
{
    if($scanner -ne $masterScanner)
    {
        # run the steps
        for($i = 0; $i -lt $translationSteps.Count; $i = $i+2)
        {
            $scanner.Coordinates = Get-RotatedPoint $scanner.Coordinates $translationSteps[$i]
            $scanner.Coordinates = $scanner.Coordinates + $translationSteps[($i+1)]
            foreach($beacon in $scanner.Beacons)
            {
                $beacon.Coordinates = Get-RotatedPoint $beacon.Coordinates $translationSteps[$i]
                $beacon.Coordinates = $beacon.Coordinates + $translationSteps[($i+1)]
            }
        }
    }
}

foreach($scanner in $scannerArray)
{
    $translationSteps = Get-PathToMasterScanner $scanner
    Invoke-LineItUpBaby $scanner $translationSteps
}

#------------- Puzzle Output
# Part 1
$allCoordinates = ($scannerArray.Beacons.Coordinates | select -unique)
Write-Host "Total Beacons: $($allCoordinates.Count)"

# Part 2
$maxManhattanDistance = 0
foreach($scannerCoordinate in $scannerArray.Coordinates)
{
    foreach($secondscannerCoordinate in $scannerArray.Coordinates)
    {
        if($scannerCoordinate -ne $secondscannerCoordinate)
        {
            $dx = [Math]::Abs($scannerCoordinate.X - $secondscannerCoordinate.X)
            $dy = [Math]::Abs($scannerCoordinate.Y - $secondscannerCoordinate.Y)
            $dz = [Math]::Abs($scannerCoordinate.Z - $secondscannerCoordinate.Z)
            $newManhattanDistance = $dx + $dy + $dz
            if($newManhattanDistance -gt $maxManhattanDistance)
            {
                $maxManhattanDistance = $newManhattanDistance
            }
        }
    }    
}
Write-Host "Max Manhattan Distance Between Scanners: $maxManhattanDistance"
