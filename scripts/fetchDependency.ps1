[CmdletBinding()]
param(
    [string]$Dependency
)

if ($PSVersionTable.PSEdition -ne "Core") {
   Import-Module BitsTransfer -Verbose:$false
}

Write-Verbose "Fetching dependency: $Dependency"

$scriptsDir = split-path -parent $MyInvocation.MyCommand.Definition
$vcpkgRootDir = & $scriptsDir\findFileRecursivelyUp.ps1 $scriptsDir .vcpkg-root

$downloadsDir = "$vcpkgRootDir\downloads"

function SelectProgram([Parameter(Mandatory=$true)][string]$Dependency)
{
    function performDownload(	[Parameter(Mandatory=$true)][string]$Dependency,
                                [Parameter(Mandatory=$true)][string]$url,
                                [Parameter(Mandatory=$true)][string]$downloadDir,
                                [Parameter(Mandatory=$true)][string]$downloadPath,
                                [Parameter(Mandatory=$true)][string]$downloadVersion,
                                [Parameter(Mandatory=$true)][string]$requiredVersion)
    {
        if (Test-Path $downloadPath)
        {
            return
        }

        # Can't print because vcpkg captures the output and expects only the path that is returned at the end of this script file
        # Write-Host "A suitable version of $Dependency was not found (required v$requiredVersion). Downloading portable $Dependency v$downloadVersion..."

        if (!(Test-Path $downloadDir))
        {
            New-Item -ItemType directory -Path $downloadDir | Out-Null
        }

        if (($PSVersionTable.PSEdition -ne "Core") -and ($Dependency -ne "git")) # git fails with BITS
        {
            try {
                $WC = New-Object System.Net.WebClient
                $ProxyAuth = !$WC.Proxy.IsBypassed($url)
                If($ProxyAuth){
                    $ProxyCred = Get-Credential -Message "Enter credentials for Proxy Authentication"
                    $PSDefaultParameterValues.Add("Start-BitsTransfer:ProxyAuthentication","Basic")
                    $PSDefaultParameterValues.Add("Start-BitsTransfer:ProxyCredential",$ProxyCred)
                }

                Start-BitsTransfer -Source $url -Destination $downloadPath -ErrorAction Stop
            }
            catch [System.Exception] {
                # If BITS fails for any reason, delete any potentially partially downloaded files and continue
                if (Test-Path $downloadPath)
                {
                    Remove-Item $downloadPath
                }
            }
        }
        if (!(Test-Path $downloadPath))
        {
            Write-Verbose("Downloading $Dependency...")
            (New-Object System.Net.WebClient).DownloadFile($url, $downloadPath)
        }
    }

    # Enums (without resorting to C#) are only available on powershell 5+.
    $ExtractionType_NO_EXTRACTION_REQUIRED = 0
    $ExtractionType_ZIP = 1
    $ExtractionType_SELF_EXTRACTING_7Z = 2


    # Using this to wait for the execution to finish
    function Invoke-Command()
    {
        param ( [string]$program = $(throw "Please specify a program" ),
                [string]$argumentString = "",
                [switch]$waitForExit )

        $psi = new-object "Diagnostics.ProcessStartInfo"
        $psi.FileName = $program
        $psi.Arguments = $argumentString
        $proc = [Diagnostics.Process]::Start($psi)
        if ( $waitForExit )
        {
            $proc.WaitForExit();
        }
    }

    function Expand-ZIPFile($file, $destination)
    {
        if (!(Test-Path $destination))
        {
            New-Item -ItemType Directory -Path $destination | Out-Null
        }

        $shell = new-object -com shell.application
        $zip = $shell.NameSpace($file)
        foreach($item in $zip.items())
        {
            # Piping to Out-Null is used to block until finished
            $shell.Namespace($destination).copyhere($item) | Out-Null
        }
    }

    if($Dependency -eq "cmake")
    {
        $requiredVersion = "3.9.3"
        $downloadVersion = "3.9.3"
        $url = "https://cmake.org/files/v3.9/cmake-3.9.3-win32-x86.zip"
        $downloadPath = "$downloadsDir\cmake-3.9.3-win32-x86.zip"
        $expectedDownloadedFileHash = "47870e3d4c9a5aa019e71020cd85cc60b6f2d2569fb239eaec204cd991e512f1"
        $executableFromDownload = "$downloadsDir\cmake-3.9.3-win32-x86\bin\cmake.exe"
        $extractionType = $ExtractionType_ZIP
        $extractionFolder = $downloadsDir
    }
    elseif($Dependency -eq "nuget")
    {
        $requiredVersion = "4.3.0"
        $downloadVersion = "4.3.0"
        $url = "https://dist.nuget.org/win-x86-commandline/v4.3.0/nuget.exe"
        $downloadPath = "$downloadsDir\nuget-$downloadVersion\nuget.exe"
        $expectedDownloadedFileHash = "386da77a8cf2b63d1260b7020feeedabfe3b65ab31d20e6a313a530865972f3a"
        $executableFromDownload = $downloadPath
        $extractionType = $ExtractionType_NO_EXTRACTION_REQUIRED
    }
    elseif($Dependency -eq "vswhere")
    {
        $requiredVersion = "2.1.4"
        $downloadVersion = "2.1.4"
        $url = "https://github.com/Microsoft/vswhere/releases/download/2.1.4/vswhere.exe"
        $downloadPath = "$downloadsDir\vswhere-$downloadVersion\vswhere.exe"
        $expectedDownloadedFileHash = "548fb9dfeed59bc4ddcce739a5729e9c8dd5932cd60ff6f74727ee069e7da458"
        $executableFromDownload = $downloadPath
        $extractionType = $ExtractionType_NO_EXTRACTION_REQUIRED
    }
    elseif($Dependency -eq "git")
    {
        $requiredVersion = "2.14.1"
        $downloadVersion = "2.14.1"
        $url = "https://github.com/git-for-windows/git/releases/download/v2.14.1.windows.1/MinGit-2.14.1-32-bit.zip" # We choose the 32-bit version
        $downloadPath = "$downloadsDir\MinGit-2.14.1-32-bit.zip"
        $expectedDownloadedFileHash = "77b468e0ead1e7da4cb3a1cf35dabab5210bf10457b4142f5e9430318217cdef"
        # There is another copy of git.exe in MinGit\bin. However, an installed version of git add the cmd dir to the PATH.
        # Therefore, choosing the cmd dir here as well.
        $executableFromDownload = "$downloadsDir\MinGit-2.14.1-32-bit\cmd\git.exe"
        $extractionType = $ExtractionType_ZIP
        $extractionFolder = "$downloadsDir\MinGit-2.14.1-32-bit"
    }
    elseif($Dependency -eq "installerbase")
    {
        $requiredVersion = "3.1.81"
        $downloadVersion = "3.1.81"
        $url = "https://github.com/podsvirov/installer-framework/releases/download/cr203958-9/QtInstallerFramework-win-x86.zip"
        $downloadPath = "$downloadsDir\QtInstallerFramework-win-x86.zip"
        $expectedDownloadedFileHash = "f2ce23cf5cf9fc7ce409bdca49328e09a070c0026d3c8a04e4dfde7b05b83fe8"
        $executableFromDownload = "$downloadsDir\QtInstallerFramework-win-x86\bin\installerbase.exe"
        $extractionType = $ExtractionType_ZIP
        $extractionFolder = $downloadsDir
    }
    else
    {
        throw "Unknown program requested"
    }

    $downloadSubdir = Split-path $downloadPath -Parent
    if (!(Test-Path $downloadSubdir))
    {
        New-Item -ItemType Directory -Path $downloadSubdir | Out-Null
    }

    performDownload $Dependency $url $downloadsDir $downloadPath $downloadVersion $requiredVersion

    #calculating the hash
    if ($PSVersionTable.PSEdition -ne "Core")
    {
        $hashAlgorithm = [Security.Cryptography.HashAlgorithm]::Create("SHA256")
        $fileAsByteArray = [io.File]::ReadAllBytes($downloadPath)
        $hashByteArray = $hashAlgorithm.ComputeHash($fileAsByteArray)
        $downloadedFileHash = -Join ($hashByteArray | ForEach-Object {"{0:x2}" -f $_})
    }
    else
    {
        $downloadedFileHash = (Get-FileHash -Path $downloadPath -Algorithm SHA256).Hash
    }

    if ($expectedDownloadedFileHash -ne $downloadedFileHash)
    {
        throw [System.IO.FileNotFoundException] ("Mismatching hash of the downloaded " + $Dependency)
    }

    if ($extractionType -eq $ExtractionType_NO_EXTRACTION_REQUIRED)
    {
        # do nothing
    }
    elseif($extractionType -eq $ExtractionType_ZIP)
    {
        if (-not (Test-Path $executableFromDownload)) # consider renaming the extraction folder to make sure the extraction finished
        {
            # Expand-Archive $downloadPath -dest "$extractionFolder" -Force # Requires powershell 5+
            Expand-ZIPFile -File $downloadPath -Destination $extractionFolder
        }
    }
    elseif($extractionType -eq $ExtractionType_SELF_EXTRACTING_7Z)
    {
        if (-not (Test-Path $executableFromDownload))
        {
            Invoke-Command $downloadPath "-y" -waitForExit:$true
        }
    }
    else
    {
        throw "Invalid extraction type"
    }

    if (-not (Test-Path $executableFromDownload))
    {
        throw [System.IO.FileNotFoundException] ("Could not detect or download " + $Dependency)
    }

    return $executableFromDownload
}

SelectProgram $Dependency

Write-Verbose "Fetching dependency: $Dependency. Done."
