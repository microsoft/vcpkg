# This script parses the sourcelink JSON files in the input directory and combines them into a single JSON file.
# During this processing, it replaces the "__VCPKG_INSTALLED_TRIPLET_DIR__" placeholder 
# produced by vcpkg_write_sourcelink_file with the installed header path.
#
# The relative options are used to specify the scanning and output locations, relative to the InstalledTripletPath.
# The ScanDirectory and OutFile options may be used instead if non-relative paths are desired.
param (
    [string]$InstalledTripletPath,
    [string]$RelativeScan,
    [string]$RelativeOutFile,
    [string]$ScanDirectory,
    [string]$OutputFile
)

$ErrorActionPreference = 'Stop'

# Fill ScanDirectory and OutFile from the relative options if they are not set
if (-not $ScanDirectory) {
    if (-not $RelativeScan) {
        Write-Host "RelativeScan is not set, but ScanDirectory is not set either"
        exit 1
    }
    $ScanDirectory = Join-Path $InstalledTripletPath $RelativeScan
}
if (-not $OutputFile) {
    if (-not $RelativeOutFile) {
        Write-Host "RelativeOutFile is not set, but OutputFile is not set either"
        exit 1
    }
    $OutputFile = Join-Path $InstalledTripletPath $RelativeOutFile
}

# Get all JSON files in the input directory, sorted so that unchanged inputs produce identical output.
# A missing directory means that no installed port provides sourcelink information.
$files = @()
if (Test-Path -LiteralPath $ScanDirectory) {
    $files = @(Get-ChildItem -LiteralPath $ScanDirectory -Filter *.json | Sort-Object Name)
}

# Initialize an ordered dictionary to hold the combined "documents" content
$combinedDocuments = [ordered]@{}

foreach ($file in $files) {
    # Read the content of the file
    $content = Get-Content -Path $file.FullName -Raw | ConvertFrom-Json

    # Extract the "documents" section
    $documents = $content.documents

    $documents.PSObject.Properties | ForEach-Object {
        $newKey = $_.Name -replace "__VCPKG_INSTALLED_TRIPLET_DIR__", $InstalledTripletPath
        $combinedDocuments[$newKey] = $_.Value
    }
}

# Create the final JSON structure
$finalJson = @{ documents = $combinedDocuments } | ConvertTo-Json -Depth 4 -Compress

# Concurrent builds may share the output file, so write to a process-specific temporary file
# and swap it into place, ensuring readers never observe a partially written file.
$TempOutputFile = "$OutputFile.$PID.tmp"
try {
    for ($attempt = 0; ; $attempt++) {
        try {
            # Preserve the timestamp when another writer has already published the same mapping.
            if ((Test-Path -LiteralPath $OutputFile) -and ([System.IO.File]::ReadAllText($OutputFile) -ceq $finalJson)) {
                break
            }
            [System.IO.File]::WriteAllText($TempOutputFile, $finalJson)
            if (Test-Path -LiteralPath $OutputFile) {
                [System.IO.File]::Replace($TempOutputFile, $OutputFile, [NullString]::Value)
            } else {
                [System.IO.File]::Move($TempOutputFile, $OutputFile)
            }
            Write-Host "Combined $($files.Count) sourcelink files from $ScanDirectory"
            break
        } catch [System.IO.IOException] {
            # A reader or competing writer can briefly prevent an atomic replacement.
            if ($attempt -ge 4) {
                throw
            }
            Start-Sleep -Milliseconds 100
        }
    }
} finally {
    if (Test-Path -LiteralPath $TempOutputFile) {
        Remove-Item -LiteralPath $TempOutputFile -Force
    }
}
