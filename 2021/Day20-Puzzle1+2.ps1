## Had to script a less than stellar bug fix in
## to account for what happens if 
## $imageEnhancementAlgorithm[0] -eq "#"
## this fix works for all cases now, except where
## $imageEnhancementAlgorithm[0 and -1] -eq "#"
## To be fair though, the algorithm breaks if both
## $imageEnhancementAlgorithm[0 and -1] -eq "#" as
## the result would always be infinity
$puzzleInput = Get-Content 'C:\Users\Nathan Ziehnert\OneDrive - Z-Nerd\Documents\AOC\2021\20\input.txt'
$imageEnhancementAlgorithm = $puzzleInput[0].ToCharArray()
$image = $puzzleInput[2..$puzzleInput.Count]

$imageEnhancementFix = if($imageEnhancementAlgorithm[0] -eq "#"){$true}else{$false}
$currentlyInfiniteOn = $false

$dx = @(-1,0,1,-1,0,1,-1,0,1)
$dy = @(-1,-1,-1,0,0,0,1,1,1)

$beginningImage = New-Object 'object[,]' $image[0].Length, $image.Count
for($y = 0; $y -lt $image.Count; $y++)
{
    for($x = 0; $x -lt $image[0].Length; $x++)
    {
        $beginningImage[$x,$y] = ($image[$y])[$x]
    }
}

function Expand-Image($imageToExpand)
{
    # expand image by one on all sides
    $imageWidth = $imageToExpand.GetLength(0)
    $imageHeight = $imageToExpand.GetLength(1)
    $expandedImage = New-Object 'object[,]' ($imageWidth+2),($imageHeight+2)
    $expandCharacter = if($currentlyInfiniteOn){"#"}else{"."}
    for($x = 0; $x -lt ($imageWidth+2); $x++)
    {
        $expandedImage[$x,0] = $expandCharacter
        $expandedImage[$x,($imageHeight+1)] = $expandCharacter
    }
    for($y = 0; $y -lt ($imageHeight+2); $y++)
    {
        $expandedImage[0,$y] = $expandCharacter
        $expandedImage[($imageWidth+1),$y] = $expandCharacter
    }
    for($x = 0; $x -lt $imageWidth; $x++)
    {
        for($y = 0; $y -lt $imageHeight; $y++)
        {
            $expandedImage[($x+1),($y+1)] = $imageToExpand[$x,$y]
        }
    }
    return ,$expandedImage
}

function Invoke-EnhanceImage($imageToEnhance)
{
    $expandedImage = Expand-Image $imageToEnhance

    # need something to put all this data into
    $newImage = New-Object 'object[,]' $expandedImage.GetLength(0),$expandedImage.GetLength(1)

    # Take each point and get it's binary value
    for($y = 0; $y -lt $expandedImage.GetLength(1); $y++)
    {
        for($x = 0; $x -lt $expandedImage.GetLength(0); $x++)
        {
            $binaryString = ""
            for($i = 0; $i -lt $dx.Count; $i++)
            {
                if( (($x+$dx[$i]) -lt 0 `
                    -or ($x+$dx[$i]) -ge $expandedImage.GetLength(0)) `
                    -or (($y+$dy[$i]) -lt 0 `
                    -or ($y+$dy[$i]) -ge $expandedImage.GetLength(1)))
                {
                    if($currentlyInfiniteOn)
                    {
                        $binaryString += "1"
                    }
                    else
                    {
                        $binaryString += "0"
                    }
                }
                else
                {
                    $binaryString += if($expandedImage[($x+$dx[$i]),($y+$dy[$i])] -eq "#"){"1"}else{"0"}
                }
            }
            $enhancementIndex = [Convert]::ToInt32($binaryString, 2)
            $newImage[$x,$y] = $imageEnhancementAlgorithm[$enhancementIndex]
        }
    }
    ,$newImage
}

function Draw-Image($image)
{
    for($y = 0; $y -lt $image.GetLength(1); $y++)
    {
        $line = ""
        for($x = 0; $x -lt $image.GetLength(0); $x++)
        {
            $line += "$($image[$x,$y])"
        }
        Write-Host $line
    }
    Write-Host ""
}

#----- Puzzle Output
# Part 1 Output
for($i = 0; $i -lt 2; $i++)
{
    $beginningImage = Invoke-EnhanceImage $beginningImage
    if($imageEnhancementFix){$currentlyInfiniteOn = !$currentlyInfiniteOn}
}
Write-Host "Puzzle One Output: $($beginningImage.Where({$_ -eq "#"}).Count)"

# Part 2 Output
for($i = 0; $i -lt 50; $i++)
{
    $beginningImage = Invoke-EnhanceImage $beginningImage
    if($imageEnhancementFix){$currentlyInfiniteOn = !$currentlyInfiniteOn}
}
Write-Host "Puzzle Two Output: $($beginningImage.Where({$_ -eq "#"}).Count)"
