$puzzleInput = Get-Content 'C:\Users\Nathan Ziehnert\OneDrive - Z-Nerd\Documents\AOC\2021\12\input.txt'
#$puzzleInput = Get-Content 'C:\Users\Nathan Ziehnert\OneDrive - Z-Nerd\Documents\AOC\2021\12\test-input.txt'
#$puzzleInput = Get-Content 'C:\Users\Nathan Ziehnert\OneDrive - Z-Nerd\Documents\AOC\2021\12\simple-input.txt'

# Get a list of caves (probably can be improved)
$caves = @()
foreach($line in $puzzleInput)
{
    $caves += $line.Split("-")
}
$caves = $caves | select -Unique

# Build the initial cave map
$caveMap = @()
foreach($cave in $caves)
{ 
    $caveMap += [pscustomobject]@{
        Name = $cave
        Size = if($cave -cmatch "^[A-Z]*$"){"large"}else{"small"}
        Neighbors = @($puzzleInput.Where({$_ -like "$cave-*" -or $_ -like "*-$cave"}).Replace("-$cave","").Replace("$cave-",""))
    }
}

# Swap neighbors for object model
for($i = 0; $i -lt $caveMap.Count; $i++)
{
    for($j = 0; $j -lt $caveMap[$i].Neighbors.Count; $j++)
    {
        $caveMap[$i].Neighbors[$j] = $caveMap.Where({$_.Name -eq $caveMap[$i].Neighbors[$j]})[0]
    }
}

function FindPaths($start, $pathVisitedNeighbors, $path, $smallCaveExtraVisit)
{
    $paths = @()
    $path = if([string]::IsNullOrEmpty($path)){$start.Name}else{$path}
    $pathVisitedNeighbors += $start
    $smallCaveExtraVisit = if($smallCaveExtraVisit -eq $null){$false}else{$smallCaveExtraVisit}
    foreach($neighbor in $start.Neighbors)
    {
        $pathOriginal = $path
        $pathVisitedNeighborsOriginal = @($pathVisitedNeighbors)
        $smallCaveExtraVisitOriginal = $smallCaveExtraVisit
        if($neighbor.Name -eq "end")
        {
            $path += ",$($neighbor.Name)"
            $paths += $path
            $pathVisitedNeighbors = $pathVisitedNeighborsOriginal
            $path = $pathOriginal
            $smallCaveExtraVisit = $smallCaveExtraVisitOriginal
            continue
        }
        elseif($neighbor.Name -eq "start")
        {
            continue
        }
        elseif($neighbor.Size -eq "large")
        {
            $path += ",$($neighbor.Name)"
            $paths += FindPaths $neighbor $pathVisitedNeighbors $path $smallCaveExtraVisit
            $pathVisitedNeighbors = $pathVisitedNeighborsOriginal
            $smallCaveExtraVisit = $smallCaveExtraVisitOriginal
            $path = $pathOriginal
        }
        else
        {
            if($pathVisitedNeighbors -contains $neighbor -and !$smallCaveExtraVisit)
            {
                $smallCaveExtraVisit = $true
                $path += ",$($neighbor.Name)"
                $paths += FindPaths $neighbor $pathVisitedNeighbors $path $smallCaveExtraVisit
                $pathVisitedNeighbors = $pathVisitedNeighborsOriginal
                $smallCaveExtraVisit = $smallCaveExtraVisitOriginal
                $path = $pathOriginal
            }
            elseif($pathVisitedNeighbors -notcontains $neighbor)
            {
                $path += ",$($neighbor.Name)"
                $paths += FindPaths $neighbor $pathVisitedNeighbors $path $smallCaveExtraVisit
                $pathVisitedNeighbors = $pathVisitedNeighborsOriginal
                $smallCaveExtraVisit = $smallCaveExtraVisitOriginal
                $path = $pathOriginal
            }
        }
    }
    return $paths
}
(FindPaths $caveMap.Where({$_.Name -eq "start"})).Count