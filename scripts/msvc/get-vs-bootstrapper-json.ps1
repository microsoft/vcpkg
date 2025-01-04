. .\vs-utility.ps1
function Get-UrlSha256 {
    param (
        [string]$Url
    )
    $uri = [System.Uri]::new($Url)
    $segments = $uri.Segments
    return $segments[-2].Trim('/')
}
function Get-UrlFilename {
    param (
        [string]$Url
    )
    $uri = [System.Uri]::new($Url)
    $segments = $uri.Segments
    return $segments[-1].Trim('/')
}

function Get-Download-Filename {
    param (
        [string]$Url,
        [string]$DownloadDir
    )
    $filename = Get-UrlFilename -Url $Url
    $combinedPath = [System.IO.Path]::Combine((Get-Location).Path, $DownloadDir, $filename)
    $absPath = [System.IO.Path]::GetFullPath($combinedPath)
    return $absPath
}
function Get-File-From-Url {
    param (
        [string]$Url,
        [string]$DownloadDir
    )
    $filePath = Get-Download-Filename -Url $Url -DownloadDir $DownloadDir
    if (-not (Test-Path -Path $DownloadDir)) {
        $res = New-Item -ItemType Directory -Path $DownloadDir
    }
    $res = Write-Host "Downloading $Url to $filePath!`n"
    if (-not (Test-Path -Path $filePath)) {
        Invoke-WebRequest -Uri $Url -OutFile $filePath -TimeoutSec 60
        if (-not (Test-Path -Path $filePath)) {
            Write-Error "Failed to download $Url to $filePath!`n"
        }
    }
    return $filePath
}

function get-vs-bootstrapper-json {
    param (
        [string]$InputJson = "msvc-input.json",
        [string]$DownloadDir = "downloads"
    )

    $DownloadDir = [System.IO.Path]::Combine((Get-Location).Path, $DownloadDir)
    $InputJson = [System.IO.Path]::Combine((Get-Location).Path, $InputJson)
    $jsonContent = Get-Content -Path $InputJson -Raw
    $jsonObject = $jsonContent | ConvertFrom-Json

    if($IsWindows) {
        $sevenzipUrl = $jsonObject.seven_zip_url
        $sevenzipSHA256 = $jsonObject.seven_zip_sha256
        $sevenzipExecutable = Get-Download-Filename -Url $sevenzipUrl -DownloadDir $DownloadDir
        $res = Write-Host "Running on Windows: $sevenzipExecutable"
        if (-not (Test-Path -Path $sevenzipExecutable)) {
            Get-File-From-Url -Url $sevenzipUrl -DownloadDir $DownloadDir
            $res = Write-Host "Downloaded 7zip to $sevenzipExecutable"
            VerifyHashOrRemoveFile -File $sevenzipExecutable -Hash $sevenzipSHA256
        }
    }
    else {
        $sevenzipExecutable = "7zz"
    }

    $installerUrl = $jsonObject.installer_url
    $installerName = Get-Download-Filename -Url $installerUrl -DownloadDir $DownloadDir
    $installerSHA256 = Get-UrlSha256 -Url $installerUrl
    $extractPath = [System.IO.Path]::Combine((Get-Location).Path, $DownloadDir, "vs-extracted")

    $jsonFilePath = $jsonObject.installer_json_path
    $targetJsonPath = [System.IO.Path]::Combine((Get-Location).Path, $DownloadDir, $jsonObject.target_json_name)

    # This json contains the URI for the fixed version channel manifest
    if (-not (Test-Path -Path $installerName)) {
        $res = Get-File-From-Url -Url $installerUrl -DownloadDir $DownloadDir
        $res = VerifyHashOrRemoveFile -File $installerName -Hash $installerSHA256
    }

    $resp = & "$sevenzipExecutable" x $installerName "$jsonFilePath" -o"$extractPath" -y

    if (Test-Path -Path "$extractPath/$jsonFilePath") {
        $res = Copy-Item -Path "$extractPath/$jsonFilePath" -Destination $targetJsonPath -Force
    } else {
        Write-Error "Couldn't copy. JSON file not found at '$extractPath/$jsonFilePath'"
    }

    if (-not (Test-Path -Path $targetJsonPath)) {
        Write-Error "JSON file not found at '$targetJsonPath'"
    }

    Remove-Item -Path $extractPath -Force -Recurse
    Remove-Item -Path $installerName -Force

    return $targetJsonPath
}