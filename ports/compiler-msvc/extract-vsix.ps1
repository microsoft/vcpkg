param (
    [Parameter(Mandatory=$true)]
    [string]$VsixFile,
    [Parameter(Mandatory=$true)]
    [string]$ExtractTo = "install"
)

Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::OpenRead(${VsixFile}).Entries |
    Where-Object { $_.FullName -like 'Contents/*' } |
    ForEach-Object { 
        $relativePath = $_.FullName.Substring(9)  # Remove 'Contents/'
        $relativePath = [System.Uri]::UnescapeDataString($relativePath)  # Decode URL-encoded characters
        $outputPath = Join-Path -Path $ExtractTo -ChildPath $relativePath
        $parentPath = [System.IO.Path]::GetDirectoryName($outputPath)
        if(-not (Test-Path -Path $parentPath)) {
            New-Item -Path $parentPath -ItemType Directory -Force
        }
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($_, $outputPath, $true)  # Extract entry to the install folder
    }
