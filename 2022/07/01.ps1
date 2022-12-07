$input = Get-Content $PSScriptRoot\input.txt

class ElfFile {
    [string]$name
    [bigint]$size
}

class ElfDirectory {
    [string]$name
    [System.Collections.Generic.List[ElfFile]]$files = [System.Collections.Generic.List[ElfFile]]@()
    [System.Collections.Generic.List[ElfDirectory]]$directories = [System.Collections.Generic.List[ElfDirectory]]@()
    [ELfDirectory]$parentDirectory = $null

    [int]size() {
        $size = 0;
        foreach($file in $this.files)
        {
            $size += $file.size
        }
        foreach($directory in $this.directories)
        {
            $size += $directory.size()
        }
        return $size
    }
}

$rootDirectory = [ElfDirectory]::new()
$rootDirectory.name = "/"

$currentDirectory = $rootDirectory
foreach($i in $input)
{
    if($i.StartsWith("$"))
    {
        $null, $cmd, $param = $i.Split(" ")
        if($cmd -eq "cd")
        { 
            if($param -eq "/")
            {
                # go to root directory
                $currentDirectory = $rootDirectory
            }
            elseif($param -eq "..")
            {
                # move up directory
                $currentDirectory = $currentDirectory.parentDirectory
            }
            else
            {
                # move down directory
                $currentDirectory = ($currentDirectory.directories.Where({$_.name -eq "$param"}))[0]
            }
        }
    }
    else
    {
        ## work on the result of the cmd
        $dirorsize, $name = $i.split(" ")
        if($dirorsize -eq "dir")
        {
            ## create a new directory
            $d = [ElfDirectory]::new()
            $d.parentDirectory = $currentDirectory
            $d.name = $name
            $currentDirectory.directories.add($d)
        }
        else
        {
            ## add file to current directory
            $f = [ElfFile]::new()
            $f.name = $name
            $f.size = $dirorsize
            [void]$currentDirectory.files.add($f)
        }
    }
}

function Get-DirectoriesWithSizes([ELfDirectory]$rootDirectory){
    $directories = [System.Collections.Generic.List[object]]@()
    [void]$directories.Add([pscustomobject]@{Name = $rootDirectory.name; Size = $rootDirectory.size()})
    foreach($d in $rootDirectory.directories)
    {
        $directories += Get-DirectoriesWithSizes $d
    }
    return $directories
}

(Get-DirectoriesWithSizes $rootDirectory | Where-Object {$_.Size -le 100000} | Measure-Object Size -Sum).sum