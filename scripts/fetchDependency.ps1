[CmdletBinding()]
param(
    [string]$Dependency
)

function Test-Command($commandName)
{
    return [bool](Get-Command -Name $commandName -ErrorAction SilentlyContinue)
}

function Test-CommandParameter($commandName, $parameterName)
{
    return (Get-Command $commandName).Parameters.Keys -contains $parameterName
}

function Test-Module($moduleName)
{
    return [bool](Get-Module -ListAvailable -Name $moduleName)
}

function Get-Credential-Backwards-Compatible()
{
    if (Test-CommandParameter -commandName 'Get-Credential' -parameterName 'Message')
    {
        return Get-Credential -Message "Enter credentials for Proxy Authentication"
    }
    else
    {
        Write-Host "Enter credentials for Proxy Authentication"
        return Get-Credential
    }
}

function Get-Hash-SHA265()
{
    if (Test-Command -commandName 'Microsoft.PowerShell.Utility\Get-FileHash')
    {
        Write-Verbose("Hashing with Microsoft.PowerShell.Utility\Get-FileHash")
        $downloadedFileHash =  (Get-FileHash -Path $downloadPath -Algorithm SHA256).Hash
    }
    elseif(Test-Command -commandName 'Pscx\Get-Hash')
    {
        Write-Verbose("Hashing with Pscx\Get-Hash")
        $downloadedFileHash =  (Get-Hash -Path $downloadPath -Algorithm SHA256).HashString
    }
    else
    {
        Write-Verbose("Hashing with .NET")
        $hashAlgorithm = [Security.Cryptography.HashAlgorithm]::Create("SHA256")
        $fileAsByteArray = [io.File]::ReadAllBytes($downloadPath)
        $hashByteArray = $hashAlgorithm.ComputeHash($fileAsByteArray)
        $downloadedFileHash = -Join ($hashByteArray | ForEach-Object {"{0:x2}" -f $_})
    }

    return $downloadedFileHash.ToLower()
}

if (Test-Module -moduleName 'BitsTransfer')
{
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

        if (!(Test-Path $downloadDir))
        {
            New-Item -ItemType directory -Path $downloadDir | Out-Null
        }

        $downloadsTemp = "$downloadDir/temp"
        if (Test-Path $downloadsTemp) # Delete temp dir if it exists
        {
            Remove-Item $downloadsTemp -Recurse -Force
        }
        if (!(Test-Path $downloadsTemp)) # Recreate temp dir. It may still be there the dir was in use
        {
            New-Item -ItemType directory -Path $downloadsTemp | Out-Null
        }

        $tempDownloadName = "$downloadsTemp/$Dependency-$downloadVersion.temp"

        $WC = New-Object System.Net.WebClient
        $ProxyAuth = !$WC.Proxy.IsBypassed($url)

         # git and installerbase fail with Start-BitsTransfer
        if ((Test-Command -commandName 'Start-BitsTransfer') -and ($Dependency -ne "git")-and ($Dependency -ne "installerbase"))
        {
            try
            {
                if ($ProxyAuth)
                {
                    $ProxyCred = Get-Credential-Backwards-Compatible
                    $PSDefaultParameterValues.Add("Start-BitsTransfer:ProxyAuthentication","Basic")
                    $PSDefaultParameterValues.Add("Start-BitsTransfer:ProxyCredential", $ProxyCred)
                }
                Start-BitsTransfer -Source $url -Destination $tempDownloadName -ErrorAction Stop
                Move-Item -Path $tempDownloadName -Destination $downloadPath
                return
            }
            catch [System.Exception]
            {
                # If BITS fails for any reason, delete any potentially partially downloaded files and continue
                if (Test-Path $tempDownloadName)
                {
                    Remove-Item $tempDownloadName
                }
            }
        }

        if ($ProxyAuth)
        {
            $WC.Proxy.Credentials = Get-Credential-Backwards-Compatible
        }

        Write-Verbose("Downloading $Dependency...")
        $WC.DownloadFile($url, $tempDownloadName)
        Move-Item -Path $tempDownloadName -Destination $downloadPath
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

        if (Test-Command -commandName 'Microsoft.PowerShell.Archive\Expand-Archive')
        {
            Write-Verbose("Extracting with Microsoft.PowerShell.Archive\Expand-Archive")
            Microsoft.PowerShell.Archive\Expand-Archive -path $file -destinationpath $destination
        }
        elseif (Test-Command -commandName 'Pscx\Expand-Archive')
        {
            Write-Verbose("Extracting with Pscx\Expand-Archive")
            Pscx\Expand-Archive -path $file -OutputPath $destination
        }
        else
        {
            Write-Verbose("Extracting via shell")
            $shell = new-object -com shell.application
            $zip = $shell.NameSpace($file)
            foreach($item in $zip.items())
            {
                # Piping to Out-Null is used to block until finished
                $shell.Namespace($destination).copyhere($item) | Out-Null
            }
        }
    }

    if($Dependency -eq "cmake")
    {
        $requiredVersion = "3.9.5"
        $downloadVersion = "3.9.5"
        $url = "https://cmake.org/files/v3.9/cmake-3.9.5-win32-x86.zip"
        $downloadPath = "$downloadsDir\cmake-3.9.5-win32-x86.zip"
        $expectedDownloadedFileHash = "dd3e183254c12f7c338d3edfa642f1ac84a763b8b9a2feabb4ad5fccece5dff9"
        $executableFromDownload = "$downloadsDir\cmake-3.9.5-win32-x86\bin\cmake.exe"
        $extractionType = $ExtractionType_ZIP
        $extractionFolder = $downloadsDir
    }
    elseif($Dependency -eq "nuget")
    {
        $requiredVersion = "4.4.0"
        $downloadVersion = "4.4.0"
        $url = "https://dist.nuget.org/win-x86-commandline/v4.4.0/nuget.exe"
        $downloadPath = "$downloadsDir\nuget-$downloadVersion\nuget.exe"
        $expectedDownloadedFileHash = "2cf9b118937eef825464e548f0c44f7f64090047746de295d75ac3dcffa3e1f6"
        $executableFromDownload = $downloadPath
        $extractionType = $ExtractionType_NO_EXTRACTION_REQUIRED
    }
    elseif($Dependency -eq "vswhere")
    {
        $requiredVersion = "2.2.11"
        $downloadVersion = "2.2.11"
        $url = "https://github.com/Microsoft/vswhere/releases/download/2.2.11/vswhere.exe"
        $downloadPath = "$downloadsDir\vswhere-$downloadVersion\vswhere.exe"
        $expectedDownloadedFileHash = "0235c2cb6341978abdf32e27fcf1d7af5cb5514c035e529c4cd9283e6f1a261f"
        $executableFromDownload = $downloadPath
        $extractionType = $ExtractionType_NO_EXTRACTION_REQUIRED
    }
    elseif($Dependency -eq "git")
    {
        $requiredVersion = "2.15.0"
        $downloadVersion = "2.15.0"
        $url = "https://github.com/git-for-windows/git/releases/download/v2.15.0.windows.1/MinGit-2.15.0-32-bit.zip"
        $downloadPath = "$downloadsDir\MinGit-2.15.0-32-bit.zip"
        $expectedDownloadedFileHash = "69c035ab7b75c42ce5dd99e8927d2624ab618fab73c5ad84c9412bd74c343537"
        # There is another copy of git.exe in MinGit\bin. However, an installed version of git add the cmd dir to the PATH.
        # Therefore, choosing the cmd dir here as well.
        $executableFromDownload = "$downloadsDir\MinGit-2.15.0-32-bit\cmd\git.exe"
        $extractionType = $ExtractionType_ZIP
        $extractionFolder = "$downloadsDir\MinGit-2.15.0-32-bit"
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

    $downloadedFileHash = Get-Hash-SHA265 $downloadPath
    if ($expectedDownloadedFileHash -ne $downloadedFileHash)
    {
        Write-Host ("`nFile does not have expected hash:`n" +
        "        File path: [ $downloadPath ]`n" +
        "    Expected hash: [ $expectedDownloadedFileHash ]`n" +
        "      Actual hash: [ $downloadedFileHash ]`n")
        throw "Invalid Hash"
    }

    if ($extractionType -eq $ExtractionType_NO_EXTRACTION_REQUIRED)
    {
        # do nothing
    }
    elseif($extractionType -eq $ExtractionType_ZIP)
    {
        if (-not (Test-Path $executableFromDownload)) # consider renaming the extraction folder to make sure the extraction finished
        {
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
        throw ("Could not detect or download " + $Dependency)
    }

    return $executableFromDownload
}

$path = SelectProgram $Dependency
Write-Verbose "Fetching dependency: $Dependency. Done."
return "<sol>::$path::<eol>"
