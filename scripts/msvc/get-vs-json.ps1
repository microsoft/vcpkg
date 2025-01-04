param (
    [string]$InputJson = "downloads/vs-bootstrapper.json",
    [string]$DownloadDir = "downloads",
    [string]$InstallDir = "install",
    [string]$BuildDir = "build"
)

$InputJson = [System.IO.Path]::Combine((Get-Location).Path, $InputJson)
$DownloadDir = [System.IO.Path]::Combine((Get-Location).Path, $DownloadDir)
$InstallDir = [System.IO.Path]::Combine((Get-Location).Path, $InstallDir)
$BuildDir = [System.IO.Path]::Combine((Get-Location).Path, $BuildDir)

function Get-SHA256Hash {
    param (
        [string]$File
    )
    return (Get-FileHash -Algorithm SHA256 -Path $File).Hash.ToLower()
}
function Get-SHA512Hash {
    param (
        [string]$File
    )
    return (Get-FileHash -Algorithm SHA512 -Path $File).Hash.ToLower()
}
function Read-Json-from-File {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FilePath
    )
    $jsonContent = Get-Content -Path $FilePath -Raw
    return $jsonContent | ConvertFrom-Json
}

function Write-CMake-Download-File {
    param (
        [string]$OutputCMakeFile = "download.cmake",
        [string]$Component,
        [string]$Context,
        [string]$Url,
        [string]$File
    )

    $cmakePrefix = "${Context}_${Component}_"
    $sha512 = Get-SHA512Hash -File $File
    $filename = Split-Path -Path $File -Leaf

    if($filename -match "payload.vsix") {
        $filename = "${Component}_${filename}"
    }

    Add-Content -Path $OutputCMakeFile -Value @(`
        "`n", `
        "set(${cmakePrefix}URL `"$Url`")", `
        "set(${cmakePrefix}SHA512 `"$sha512`")", `
        "set(${cmakePrefix}FILENAME `"${filename}`")", `
        "list(APPEND ${Context}_FILES ${Component})" `
        )

}

. .\vs-utility.ps1
function Test-Manifest-or-Download {
    param (
        [string]$BootstrapperJsonFile
    )
    $basedir = Split-Path -Parent $BootstrapperJsonFile
    $sha256 = Get-SHA256Hash -File $BootstrapperJsonFile
    $basedir = Join-Path -Path $basedir -ChildPath "vs-$sha256"
    if (-not (Test-Path -Path $basedir)) {
        New-Item -ItemType Directory -Path $basedir
    }
    $channelJsonFile = Join-Path -Path $basedir -ChildPath "channel.json"
    $manifestJsonFile = Join-Path -Path $basedir -ChildPath "manifest.json"

    if (-not (Test-Path -Path $manifestJsonFile)) {
        Get-VSManifestFromBootstrapperJson `
            -BootstrapperJsonFile $BootstrapperJsonFile `
            -ChannelJsonFile $channelJsonFile `
            -ManifestJsonFile $manifestJsonFile
    }

    return $manifestJsonFile
}

function Get-VSManifestFromBootstrapperJson {
    param (
        [Parameter(Mandatory=$true)]
        [string]$BootstrapperJsonFile,
        [Parameter(Mandatory=$true)]
        [string]$ChannelJsonFile,
        [Parameter(Mandatory=$true)]
        [string]$ManifestJsonFile
    )
    $bootstrapperJson = Read-Json-from-File -FilePath $BootstrapperJsonFile
    $channelUri = $bootstrapperJson.installChannelUri
    $previewStr = ""
    Invoke-Download -Url $channelUri -OutputPath $ChannelJsonFile
    ## Download Manifest
    $channelJson = Read-Json-from-File -FilePath $ChannelJsonFile
    $channelItemJson = $channelJson.channelItems
    $manifestEntry = $channelItemJson | Where-Object { $_.id -eq "Microsoft.VisualStudio.Manifests.VisualStudio$previewStr" }
    if ($manifestEntry.Count -ne 1) {
        throw "Only one manifest entry is expected"
    }
    $manifestEntry = $manifestEntry[0]
    if ($manifestEntry.payloads.Count -ne 1) {
        throw "Only one payload expected"
    }
    if ($manifestEntry.payloads[0].fileName -ne "VisualStudio$previewStr.vsman") {
        throw "Only one manifest entry is expected"
    }
    Invoke-Download -Url $manifestEntry.payloads[0].url -OutputPath $ManifestJsonFile
}

function Get-LatestVersionsFromManifest {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ManifestJsonPath
    )

    $manifest = Read-Json-from-File -FilePath $ManifestJsonPath

    $msvc = @{}
    $sdk = @{}
    $redist = @{}
    $net = @{}
    $latest_msvc = @(0,0,0,0)
    $latest_redist = @(0,0,0,0)
    $build_version = 0
    $latest_sdk = @(0,0,0,0)
    $sdk_build_version = 0
    $latest_net = @(0,0,0)
    $net_build_version = 0

    foreach ($pitem in $manifest.packages) {
        $id = $pitem.id.ToLower()
        if ($id.StartsWith("microsoft.visualstudio.component.vc.") -and $id.EndsWith(".x86.x64")) {
            $pver = ($id -split "\.")[4..7] -join "."
            if ($pver[0] -match '\d') {
                $msvc[$pver] = $id
                $version_tuple = $pver -split "\." | ForEach-Object { [int]$_ }
                if (($version_tuple -join '.') -gt ($latest_msvc -join '.')) {
                    $latest_msvc = $version_tuple
                    $build_version = $pitem.version
                }
            }
        }
        elseif ($id.StartsWith("microsoft.visualstudio.component.windows10sdk.") -or $id.StartsWith("microsoft.visualstudio.component.windows11sdk.")) {
            $pver = ($id -split "\.")[-1]
            if ($pver -match '^\d+$') {
                $sdk[$pver] = $id
                $version_tuple = $pver -split "\." | ForEach-Object { [int]$_ }
                if (($version_tuple -join '.') -gt ($latest_sdk -join '.')) {
                    $latest_sdk = $version_tuple
                    $sdk_build_version = $pitem.version
                }
            }
        }
        elseif ($id.StartsWith("microsoft.vc.") -and $id.EndsWith(".crt.redist.x64.base")) {
            # Microsoft.VC.14.40.17.10.CRT.Redist.X64.base
            $pver = ($id -split "\.")[2..5] -join "."
            if ($pver[0] -match '\d') {
                $redist[$pver] = $id
                $version_tuple = $pver -split "\." | ForEach-Object { [int]$_ }
                if (($version_tuple -join '.') -gt ($latest_redist -join '.')) {
                    $latest_redist = $version_tuple
                    $redist_build_version = $pitem.version
                }
            }
        }
        elseif ($id.StartsWith("microsoft.net.") -and $id.contains(".sdk")) {
            $pver = ($id -split "\.")[2..3] -join "."
            if ($pver[0] -match '\d') {
                $net[$pver] = $id
                $version_tuple = $pver -split "\." | ForEach-Object { [int]$_ }
                if (($version_tuple -join '.') -gt ($latest_redist -join '.')) {
                    $latest_net = $version_tuple
                    $net_build_version = $pitem.version
                }
            }
        }
    }

    return @{
        "msvc" = ($latest_msvc -join ".")
        "sdk" = ($latest_sdk -join ".")
        "redist" = ($latest_redist -join ".")
        "net" = ($latest_net -join ".")
        "msvc-build-version" = $build_version
        "sdk-build-version" = $sdk_build_version
        "redist-build-version" = $redist_build_version
        "net-build-version" = $net_build_version
    }
}

function Get-MsvcToolkitBuildVersion {
    param (
        [Parameter(Mandatory = $true)]
        [array]$ComponentsJson,

        [Parameter(Mandatory = $true)]
        [string]$Version
    )

    foreach ($item in $ComponentsJson) {
        if ($item.id.ToLower() -eq "microsoft.vc.$Version.crt.headers".ToLower()) {
            return $item.version
        }
    }
    return $null
}

function Install-WindowsSDKs {
    param (
        [string]$BuildFolder,
        [string]$PackageFolder,
        [string]$JsonDataFile
    )
    $jsonData = Read-Json-from-File -FilePath $JsonDataFile
    $payloads = $jsonData.data.payloads

    $downloadFolderSdk = New-Item -Path $BuildFolder -ItemType Directory -Force
    $installFolderSdk = New-Item -Path $PackageFolder -ItemType Directory -Force

    $msi = @()

    $sdk_folder = $jsonData.'sdk-folder'

    Write-Host "Downloading Windows SDKs..."

    $sdk_cmake_file = "download_sdk.cmake"

    Add-Content -Path $sdk_cmake_file -Value @(`
        "`n", `
        "set(WinSDK_VERSION `"${sdk_folder}`")"`
    )

    # Download the SDKs
    $counter = 0
    foreach ($payload in $payloads) {
        $filename = $payload.fileName #-replace '\\', '/'
        $filePath = Join-Path -Path $downloadFolderSdk -ChildPath $filename
        $parentPath = Split-Path -Path $filePath -Parent
        if(-not (Test-Path -Path $parentPath)) {
            $newfolder = New-Item -Path $parentPath -ItemType Directory -Force
        }     
        Write-Host "Downloading $filePath"
        Invoke-Download-with-Check -Url $payload.url -OutputPath $filePath -Check  $payload.sha256
        Write-CMake-Download-File -OutputCMakeFile $sdk_cmake_file -Component "$counter" -Context "WinSDK" -Url $payload.url -File $filePath
        if ($filePath -match '\.msi$') {
            $msi += $filePath
        }
        $counter++
    }

    Write-Host "Unpacking MSI files..."
    $msi = @()

    $skipList = @(
        "MsiVal2-x86_en-us",
        "Orca-x86_en-us",
        "Windows App Certification Kit x86-x86_en-us",
        "Windows App Certification Kit x86 (OnecoreUAP)-x86_en-us",
        "Windows SDK for Windows Store Apps Legacy Tools-x86_en-us",
        "Windows SDK-x86_en-us"
    )

    $skipMatch = @(
        "DirectX",
        "Certification Kit Native Components",
        "Windows App Certification Kit Native Components",
        "Universal CRT Tools",
        "Application Verifier"
    )

    $extraCat = @(
        "ApplicationVerifierx64ExternalPackage(DesktopEditions)-x64_en-us",
        "ApplicationVerifierx64ExternalPackage(OnecoreUAP)-x64_en-us"
    )

    # Run MSI installers
    foreach ($m in $msi) {
        $skip = $false
        $msiFilePath = [System.IO.Path]::GetFullPath($m)
        $componentName = [System.IO.Path]::GetFileNameWithoutExtension($msiFilePath)
        if ($skipList -contains $componentName -or ($skipMatch | ForEach-Object { $componentName -like "*$_*" })) {
            $skip = $true
            Write-Host "Skipping '$componentName'"
        }
        Write-Host "Extracting '$componentName'"
        $componentName = $componentName -replace ' ', ''
        $installLocation = Join-Path -Path $installFolderSdk -ChildPath "single_components\$componentName"

        if ($IsWindows) {
            Start-Process -FilePath "msiexec.exe" -ArgumentList "/a `"$msiFilePath`" /quiet /qn TARGETDIR=`"$installLocation`"" -Wait
            Remove-Item -Path (Join-Path -Path $installLocation -ChildPath (Get-Item -Path $msiFilePath).Name) -Force
        }

        $filesAndDirs = Get-ChildItem -Path $installLocation
        if (-not $filesAndDirs) {
            Write-Host "Installer had no files or dirs to extract"
        }

        if ((Test-Path -Path $installLocation) -and -not $skip) {
            Copy-Item -Path $installLocation -Destination $installFolderSdk -Recurse -Force
        } else {
            Write-Host "Skipping '$componentName'"
        }

        if ($skip -and ($extraCat | ForEach-Object { $componentName -like "*$_*" })) {
            $catFiles = Get-ChildItem -Path $installLocation -Recurse -Filter *.cat
            $catalogsPath = Join-Path -Path $installFolderSdk -ChildPath "Program Files\Windows Kits\10\Catalogs"
            $response = New-Item -Path $catalogsPath -ItemType Directory -Force
            foreach ($catFile in $catFiles) {
                Copy-Item -Path $catFile.FullName -Destination $catalogsPath -Force
            }
        }

        if ($componentName -like "WindowsAppCertificationKitNativeComponents-x64_en-us") {
            $kitsPath = Join-Path -Path $installFolderSdk -ChildPath "Program Files\Windows Kits"
            $response = New-Item -Path $kitsPath -ItemType Directory -Force
            Copy-Item -Path (Join-Path -Path $installLocation -ChildPath "Windows Kits") -Destination $kitsPath -Recurse -Force
        }
    }
}

function Install-MsvcToolkit {
    param (
        [string]$BuildFolder,
        [string]$PackageFolder,
        [string]$JsonDataFile
    )
    $jsonData = Read-Json-from-File -FilePath $JsonDataFile
    $vctoolkits = $jsonData.data

    $downloadFolderVctoolkit = New-Item -Path $BuildFolder -ItemType Directory -Force
    $installFolderVctoolkit = New-Item -Path $PackageFolder -ItemType Directory -Force

    # Filter the data
    $vctoolkits = $vctoolkits | Where-Object { `
             $_.id.ToLower() -notmatch "hostarm" `
        -and $_.id.ToLower() -notmatch "hostx86" `
        -and $_.id.ToLower() -notmatch "spectre"}

    $counter = 0
    foreach ($toolkit in $vctoolkits) {
        $payloads = $toolkit.payloads
        $id = $toolkit.id
        foreach ($payload in $payloads) {
            $counter++
            $filename = $payload.fileName
            $filePath = Join-Path -Path $downloadFolderVctoolkit -ChildPath $filename
            $parentPath = Split-Path -Path $filePath -Parent
            if(-not (Test-Path -Path $parentPath)) {
                $response = New-Item -Path $parentPath -ItemType Directory -Force
            }
            $response = Invoke-Download-with-Check -Url $payload.url -OutputPath $filePath -Check $payload.sha256
            Write-CMake-Download-File -OutputCMakeFile "download_toolkit.cmake" -Component "${id}_${counter}" -Context "VCToolkit" -Url $payload.url -File $filePath

            Write-Host "Extracting $filename"
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            # Extract only entries in the "Contents/" folder
            # [System.IO.Compression.ZipFile]::OpenRead($filePath).Entries |
            #     Where-Object { $_.FullName -like "Contents/*" } |
            #     ForEach-Object { 
            #         $relativePath = $_.FullName.Substring(9)  # Remove "Contents/"
            #         $outputPath = Join-Path -Path $installFolderVctoolkit -ChildPath $relativePath
            #         $parentPath = [System.IO.Path]::GetDirectoryName($outputPath)
            #         if(-not (Test-Path -Path $parentPath)) {
            #             $response = New-Item -Path $parentPath -ItemType Directory -Force
            #         }
            #         [System.IO.Compression.ZipFileExtensions]::ExtractToFile($_, $outputPath, $true)  # Extract entry to the install folder
            #     }
        }
    }
}

function Install-MSBuild {
    param (
        [string]$BuildFolder,
        [string]$PackageFolder,
        [string]$JsonDataFile
    )
    $msi = @()

    $download_folder = New-Item -Path $BuildFolder -ItemType Directory -Force
    $install_folder = New-Item -Path $PackageFolder -ItemType Directory -Force
    $jsonData = Read-Json-from-File -FilePath $JsonDataFile
    $payloads = $jsonData.data

    Write-Host "$JsonDataFile : $jsonData"

    $count=0
    foreach ($installer in $payloads) {
        Write-Host "$installer"
        if (-not $installer.PSObject.Properties["payloads"] ) {
            Write-Host "No Payloads"
            continue
        }
        $payloads = $installer.payloads
        $download_folder_msbuild = Join-Path -Path $download_folder -ChildPath "MSBuild\$($installer.id.ToLower())"
        $name = $installer.id
        if (-not (Test-Path -Path $download_folder_msbuild)) {
            $response = New-Item -ItemType Directory -Path $download_folder_msbuild -Force
        }
        foreach ($payload in $payloads) {
            $filename = $payload.fileName
            $filepath = Join-Path -Path $download_folder_msbuild -ChildPath $filename
            $parentpath = Split-Path -Parent $filepath
            if (-not (Test-Path -Path $parentpath)) {
                $response = New-Item -ItemType Directory -Path $parentpath -Force
            }            
            if ([System.IO.Path]::GetExtension($filepath) -eq ".vsix") {
                $response = Invoke-Download-with-Check -Url $payload.url -OutputPath $filepath -Check $payload.sha256
                Write-CMake-Download-File -OutputCMakeFile "download_msbuild.cmake" -Component ${name} -Context "MSBuild" -Url $payload.url -File $filepath
                $count++
                Write-Host "Extracting $filename"
                Add-Type -AssemblyName System.IO.Compression.FileSystem
                # Extract only entries in the "Contents/" folder
                # [System.IO.Compression.ZipFile]::OpenRead($filePath).Entries |
                #     Where-Object { $_.FullName -like "Contents/*" } |
                #     ForEach-Object { 
                #         $relativePath = $_.FullName.Substring(9)  # Remove "Contents/"
                #         $outputPath = Join-Path -Path $install_folder -ChildPath $relativePath
                #         $parentPath = [System.IO.Path]::GetDirectoryName($outputPath)
                #         if(-not (Test-Path -Path $parentPath)) {
                #             $response = New-Item -Path $parentPath -ItemType Directory -Force
                #         }
                #         [System.IO.Compression.ZipFileExtensions]::ExtractToFile($_, $outputPath, $true)  # Extract entry to the install folder
                #     }
            }
        }
    }

    # Cleanup mess with MSBuild and Msbuild
    if ($env:OS -ne "Windows_NT") {
        Copy-Item -Path (Join-Path -Path $install_folder -ChildPath "Msbuild") -Destination (Join-Path -Path $install_folder -ChildPath "MSBuild") -Recurse -Force
        Copy-Item -Path (Join-Path -Path $install_folder -ChildPath "MSBUILD") -Destination (Join-Path -Path $install_folder -ChildPath "MSBuild") -Recurse -Force
        Remove-Item -Path (Join-Path -Path $install_folder -ChildPath "Msbuild") -Recurse -Force
        Remove-Item -Path (Join-Path -Path $install_folder -ChildPath "MSBUILD") -Recurse -Force
    }
}


# Load the manifest JSON file
$scriptPath = Split-Path -Path $MyInvocation.MyCommand.Path
$manifestJsonFile = Test-Manifest-or-Download -BootstrapperJsonFile $InputJson
$manifestJson = Read-Json-from-File -FilePath $manifestJsonFile

# Get toolkit and SDK versions
$toolkitAndSdkVersions = Get-LatestVersionsFromManifest -ManifestJsonPath $manifestJsonFile

# Extract SDK version and filter WinSDK packages
$extractedSdkVersion = "10.0.$($toolkitAndSdkVersions['sdk'])"
$winSdk = $manifestJson.packages | Where-Object { $_.id.ToLower() -eq "win11sdk_$extractedSdkVersion".ToLower() }
$winSdk = $winSdk[0]
$sdkVersion = $winSdk.version

# Filter VC toolkits
$vcVersion = $toolkitAndSdkVersions["msvc"]
$redistVersion = $toolkitAndSdkVersions["redist"]
$netVersion = $toolkitAndSdkVersions["net"]

$vcToolkits = $manifestJson.packages | Where-Object {
    $_.id.ToLower().StartsWith("microsoft.vc.$vcVersion") -or
    ($_.id.ToLower().StartsWith("microsoft.vc.$redistVersion") -and $_.id.ToLower().contains("redist") )  -or
    $_.id.ToLower().Contains("microsoft.visualcpp.servicing.redist") -or
    $_.id.ToLower().Contains("vsdevcmd") -or
    $_.id.ToLower().Contains(".visualcpp.tools.core") -or
    $_.id.ToLower().Contains("microsoft.visualcpp.tools.") -or
    $_.id.ToLower().Contains("microsoft.visualstudio.vc.vcvars") -or
    $_.id.ToLower().Contains("microsoft.visualcpp.dia.sdk") -or
    $_.id.ToLower().Contains("microsoft.visualcpp.servicing.diasdk") -or
    $_.id.ToLower().Contains("microsoft.net.$netVersion")
} | Where-Object {
    -not $_.language -or $_.language.ToLower() -eq "en-us" -or $_.language.ToLower() -eq "neutral"
}

$toolkitBuildVersion = Get-MsvcToolkitBuildVersion -ComponentsJson $vcToolkits -Version $vcVersion

$toolkitAndSdkVersions["product-version"] = $manifestJson.info.productSemanticVersion
$toolkitAndSdkVersions["crt-version"] = Get-MsvcToolkitBuildVersion -ComponentsJson $vcToolkits -Version $vcVersion

Write-Host $toolkitAndSdkVersions

# Generate SDK JSON and save to file
$sdkJson = @{
    "product-version"   = $toolkitAndSdkVersions["product-version"]
    "sdk-full-version"  = $sdkVersion
    "sdk-version"       = $extractedSdkVersion
    "sdk-folder"        = "$extractedSdkVersion.0"
    "sdk-build-version" = $toolkitAndSdkVersions["sdk-build-version"]
    "data"              = $winSdk
}
$sdkJsonFile = Join-Path -Path $scriptPath -ChildPath "winsdk.json"
$sdkJson | ConvertTo-Json -Depth 6 | Set-Content -Path $sdkJsonFile

# Generate MSVC JSON and save to file
$msvcJson = @{
    "product-version"   = $toolkitAndSdkVersions["product-version"]
    "msvc-version"      = $toolkitAndSdkVersions["msvc"]
    "msvc-build-version" = $toolkitAndSdkVersions["msvc-build-version"]
    "crt-version"       = $toolkitAndSdkVersions["crt-version"]
    "redist"            = $toolkitAndSdkVersions["redist"]
    "redist-version"    = $toolkitAndSdkVersions["redist-build-version"]
    "net"            = $toolkitAndSdkVersions["net"]
    "net-version"    = $toolkitAndSdkVersions["net-build-version"]
    "data"              = $vcToolkits
}
$msvcJsonFile = Join-Path -Path $scriptPath -ChildPath "msvc.json"
$msvcJson | ConvertTo-Json -Depth 6 | Set-Content -Path $msvcJsonFile

# Filter MSBuild packages with exclusions
$msBuild = $manifestJson.packages | Where-Object {
    $_.id.ToLower().Contains("msbuild") -or
    $_.id.ToLower().Contains(".build") -or
    $_.id.ToLower().Contains("microsoft.codeanalysis.compilers") -or
    $_.id.ToLower().Contains(".build.tasks.setup")
} | Where-Object {
    -not $_.language -or $_.language.ToLower() -eq "en-us" -or $_.language.ToLower() -eq "neutral"
} | Where-Object {
    -not $_.productArch -or $_.productArch.ToLower() -eq "x64" -or $_.productArch.ToLower() -eq "neutral"
} | Where-Object {
    -not $_.id.ToLower().Contains(".v141") -and
    -not $_.id.ToLower().Contains(".v142") -and
    -not $_.id.ToLower().Contains(".v150") -and
    -not $_.id.ToLower().Contains(".v160") -and
    -not $_.id.ToLower().Contains("maui") -and
    -not $_.id.ToLower().Contains("typescript") -and
    -not $_.id.ToLower().Contains(".azure") -and
    -not $_.id.ToLower().Contains(".dockertools") -and
    -not $_.id.ToLower().Contains(".unittest") -and
    -not $_.id.ToLower().Contains(".desktopbridge") -and
    -not $_.id.ToLower().Contains(".product.buildtools") -and
    -not $_.id.ToLower().Contains(".testtools.")
}

# Extract main MSBuild package data
$msBuildData = $msBuild | Where-Object { $_.id.ToLower().Contains("microsoft.build") }
$msBuildData = $msBuildData[0]

# Generate MSBuild JSON and save to file
$msBuildJson = @{
    "product-version" = ($msBuildData.version -split "\.")[0..2] -join "."
    "data" = $msBuild
}
$msBuildJsonFile = Join-Path -Path $scriptPath -ChildPath "msbuild.json"
$msBuildJson | ConvertTo-Json -Depth 6 | Set-Content -Path $msBuildJsonFile

#Install-WindowsSDKs -BuildFolder $buildDir -PackageFolder $installDir -JsonDataFile $sdkJsonFile
#Install-MsvcToolkit -BuildFolder $buildDir -PackageFolder $installDir -JsonDataFile $msvcJsonFile
#Install-MSBuild -BuildFolder $buildDir -PackageFolder $installDir -JsonDataFile $msBuildJsonFile