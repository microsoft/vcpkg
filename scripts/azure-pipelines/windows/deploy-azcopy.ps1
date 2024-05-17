$azcopyZipPath = "$PSScriptRoot\azcopyv10.zip"
& curl.exe -L -o $azcopyZipPath 'https://azcopyvnext.azureedge.net/releases/release-10.24.0-20240326/azcopy_windows_amd64_10.24.0.zip'
Expand-Archive -LiteralPath $azcopyZipPath -DestinationPath $env:PROGRAMFILES
Remove-Item -LiteralPath $azcopyZipPath -Force
