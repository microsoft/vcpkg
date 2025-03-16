# This script parses the sourcelink JSON files in the input directory and combines them into a single JSON file.
# During this processing, it replaces the "__VCPKG_INSTALLED_TRIPLET_DIR__" placeholder 
# produced by vcpkg_write_sourcelink_file with the installed header path.
#
# The relative options are used to specifiy the scanning and output locations, relative to the InstalledTripletPath.
# The ScanDirectory and OutFile options may be used instead if non-relative paths are desired.
param (
    [string]$InstalledTripletPath,
    [string]$RelativeScan,
    [string]$RelativeOutFile,
    [string]$ScanDirectory,
    [string]$OutputFile
)

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

if (-not (Test-Path $ScanDirectory)) {
    Write-Host "No files found in $ScanDirectory"
    exit 1
}

# Write to a temporary file, and only replace the output file if the content has changed.
# This avoids unnecessary triggering of rebuilds via timestamp change.
$TempOutputFile = $OutputFile + ".tmp"
Clear-Content -Path $TempOutputFile -ErrorAction SilentlyContinue

# Get all JSON files in the input directory
$files = Get-ChildItem -Path $ScanDirectory -Filter *.json

# Initialize a hashtable to hold the combined "documents" content
$combinedDocuments = @{}

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
$finalJson = @{
    documents = $combinedDocuments
}

# Write the combined content to the output file
$finalJson | ConvertTo-Json -Depth 4 -Compress | Out-File -FilePath $TempOutputFile -Encoding ascii

# Compare the temporary File with the output file, and only replace it if they are different
if (-not (Test-Path $OutputFile) -or ((Get-Content $TempOutputFile -Raw) -ne (Get-Content $OutputFile -Raw))) {
    $numFiles = $files.Count
    Write-Host "Combined $numFiles sourcelink files from $ScanDirectory"
    Move-Item -Path $TempOutputFile -Destination $OutputFile -Force
} else {
    Remove-Item -Path $TempOutputFile -Force
}
