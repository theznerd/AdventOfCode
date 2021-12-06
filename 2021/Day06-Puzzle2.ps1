$fishies = [System.Collections.Generic.List[int]]@(3,3,5,1,1,3,4,2,3,4,3,1,1,3,3,1,5,4,4,1,4,1,1,1,3,3,2,3,3,4,2,5,1,4,1,2,2,4,2,5,1,2,2,1,1,1,1,4,5,4,3,1,4,4,4,5,1,1,4,3,4,2,1,1,1,1,5,2,1,4,2,4,2,5,5,5,3,3,5,4,5,1,1,5,5,5,2,1,3,1,1,2,2,2,2,1,1,2,1,5,1,2,1,2,5,5,2,1,1,4,2,1,4,2,1,1,1,4,2,5,1,5,1,1,3,1,4,3,1,3,2,1,3,1,4,1,2,1,5,1,2,1,4,4,1,3,1,1,1,1,1,5,2,1,5,5,5,3,3,1,2,4,3,2,2,2,2,2,4,3,4,4,4,1,2,2,3,1,1,4,1,1,1,2,1,4,2,1,2,1,1,2,1,5,1,1,3,1,4,3,2,1,1,1,5,4,1,2,5,2,2,1,1,1,1,2,3,3,2,5,1,2,1,2,3,4,3,2,1,1,2,4,3,3,1,1,2,5,1,3,3,4,2,3,1,2,1,4,3,2,2,1,1,2,1,4,2,4,1,4,1,4,4,1,4,4,5,4,1,1,1,3,1,1,1,4,3,5,1,1,1,3,4,1,1,4,3,1,4,1,1,5,1,2,2,5,5,2,1,5)
$generations = 256
$fishiesByAge = [PSCustomObject]@{
    Gestation0 = ($fishies | Where-Object {$_ -eq 0}).Count
    Gestation1 = ($fishies | Where-Object {$_ -eq 1}).Count
    Gestation2 = ($fishies | Where-Object {$_ -eq 2}).Count
    Gestation3 = ($fishies | Where-Object {$_ -eq 3}).Count
    Gestation4 = ($fishies | Where-Object {$_ -eq 4}).Count
    Gestation5 = ($fishies | Where-Object {$_ -eq 5}).Count
    Gestation6 = ($fishies | Where-Object {$_ -eq 6}).Count
    Gestation7 = ($fishies | Where-Object {$_ -eq 7}).Count
    Gestation8 = ($fishies | Where-Object {$_ -eq 8}).Count
}
for($g = 0; $g -lt $generations; $g++)
{
    $newFishies = $fishiesByAge.Gestation0
    $fishiesByAge.Gestation0 = $fishiesByAge.Gestation1
    $fishiesByAge.Gestation1 = $fishiesByAge.Gestation2
    $fishiesByAge.Gestation2 = $fishiesByAge.Gestation3
    $fishiesByAge.Gestation3 = $fishiesByAge.Gestation4
    $fishiesByAge.Gestation4 = $fishiesByAge.Gestation5
    $fishiesByAge.Gestation5 = $fishiesByAge.Gestation6
    $fishiesByAge.Gestation6 = $fishiesByAge.Gestation7 + $newFishies 
    $fishiesByAge.Gestation7 = $fishiesByAge.Gestation8
    $fishiesByAge.Gestation8 = $newFishies
}
$totalFishies = $fishiesByAge.Gestation0 + $fishiesByAge.Gestation1 + $fishiesByAge.Gestation2 + $fishiesByAge.Gestation3 + $fishiesByAge.Gestation4 + $fishiesByAge.Gestation5 + $fishiesByAge.Gestation6 + $fishiesByAge.Gestation7 + $fishiesByAge.Gestation8 
$totalFishies
