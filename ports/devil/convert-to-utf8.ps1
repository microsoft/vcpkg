param([string]$filePath)

[System.Io.File]::ReadAllText($filePath) | Out-File -filepath $filePath -Encoding 'utf8' 
