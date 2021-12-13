$puzzleInput = Get-Content 'C:\Users\Nathan Ziehnert\OneDrive - Z-Nerd\Documents\AOC\2021\12\input.txt'

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

function FindPaths($start, $pathVisitedNeighbors, $path)
{
    $paths = @()
    $path = if([string]::IsNullOrEmpty($path)){$start.Name}else{$path}
    $pathVisitedNeighbors += $start
    foreach($neighbor in $start.Neighbors)
    {
        $pathOriginal = $path
        $pathVisitedNeighborsOriginal = @($pathVisitedNeighbors)
        if($neighbor.Name -eq "end")
        {
            $path += ",$($neighbor.Name)"
            $paths += $path
            $pathVisitedNeighbors = $pathVisitedNeighborsOriginal
            $path = $pathOriginal
            continue
        }
        elseif($neighbor.Size -eq "large" -or $pathVisitedNeighbors -notcontains $neighbor)
        {
            $path += ",$($neighbor.Name)"
            $paths += FindPaths $neighbor $pathVisitedNeighbors $path
            $pathVisitedNeighbors = $pathVisitedNeighborsOriginal
            $path = $pathOriginal
        }
    }
    return $paths
}
(FindPaths $caveMap.Where({$_.Name -eq "start"})).Count


<#
function FindPaths($start, $visitedCaves)
{
    $visitedCaves += $start
    foreach($neighbor in $start.Neighbors)
    {
        if($visitedCaves.Size -eq "large" -or $visitedCaves -notcontains $neighbor)
        {
            FindPaths $neighbor $visitedCaves
        }
    }
}
FindPaths $caveMap.Where({$_.Name -eq "start"})
#>
