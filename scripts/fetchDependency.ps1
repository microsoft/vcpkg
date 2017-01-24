[CmdletBinding()]
param(
    [string]$Dependency
)

Import-Module BitsTransfer

$scriptsDir = split-path -parent $MyInvocation.MyCommand.Definition
$vcpkgRootDir = & $scriptsDir\findFileRecursivelyUp.ps1 $scriptsDir .vcpkg-root

$downloadsDir = "$vcpkgRootDir\downloads"

function SelectProgram([Parameter(Mandatory=$true)][string]$Dependency)
{
    function promptForDownload([string]$title, [string]$message, [string]$yesDescription, [string]$noDescription)
    {
        if ((Test-Path "$downloadsDir\AlwaysAllowEverything") -Or (Test-Path "$downloadsDir\AlwaysAllowDownloads"))
        {
            return $true
        }

        $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", $yesDescription
        $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", $noDescription
        $AlwaysAllowDownloads = New-Object System.Management.Automation.Host.ChoiceDescription "&Always Allow Downloads", ($yesDescription + "(Future download prompts will not be displayed)")

        $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no, $AlwaysAllowDownloads)
        $result = $host.ui.PromptForChoice($title, $message, $options, 0)

        switch ($result)
            {
                0 {return $true}
                1 {return $false}
                2 {
                    New-Item "$downloadsDir\AlwaysAllowDownloads" -type file -force | Out-Null
                    return $true
                }
            }

        throw "Unexpected result"
    }


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

        $title = "Download " + $Dependency
        $message = ("No suitable version of " + $Dependency  + " was found (requires $requiredVersion or higher). Download portable version?")
        $yesDescription = "Downloads " + $Dependency + " v" + $downloadVersion +" app-locally."
        $noDescription = "Does not download " + $Dependency + "."

        $userAllowedDownload = promptForDownload $title $message $yesDescription $noDescription
        if (!$userAllowedDownload)
        {
            throw [System.IO.FileNotFoundException] ("Could not detect suitable version of " + $Dependency + " and download not allowed")
        }

        if (!(Test-Path $downloadDir))
        {
            New-Item -ItemType directory -Path $downloadDir | Out-Null
        }

        if ($Dependency -ne "git") # git fails with BITS
        {
            Start-BitsTransfer -Source $url -Destination $downloadPath -ErrorAction SilentlyContinue
        }
        else
        {
            if (!(Test-Path $downloadPath))
            {
                Write-Host("Downloading $Dependency...")
                (New-Object System.Net.WebClient).DownloadFile($url, $downloadPath)
            }
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
            Write-Host($file)
            Write-Host($destination)
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
        $requiredVersion = "3.7.2"
        $downloadVersion = "3.7.2"
        $url = "https://cmake.org/files/v3.7/cmake-3.7.2-win32-x86.zip"
        $downloadName = "cmake-3.7.2-win32-x86.zip"
        $expectedDownloadedFileHash = "ec5e299d412e0272e01d4de5bf07718f42c96361f83d51cc39f91bf49cc3e5c3"
        $executableFromDownload = "$downloadsDir\cmake-3.7.2-win32-x86\bin\cmake.exe"
        $extractionType = $ExtractionType_ZIP
    }
    elseif($Dependency -eq "nuget")
    {
        $requiredVersion = "1.0.0"
        $downloadVersion = "3.4.3"
        $url = "https://dist.nuget.org/win-x86-commandline/v3.4.3/nuget.exe"
        $downloadName = "nuget.exe"
        $expectedDownloadedFileHash = "3B1EA72943968D7AF6BACDB4F2F3A048A25AFD14564EF1D8B1C041FDB09EBB0A"
        $executableFromDownload = "$downloadsDir\nuget.exe"
        $extractionType = $ExtractionType_NO_EXTRACTION_REQUIRED
    }
    elseif($Dependency -eq "git")
    {
        $requiredVersion = "2.0.0"
        $downloadVersion = "2.8.3"
        $url = "https://github.com/git-for-windows/git/releases/download/v2.8.3.windows.1/PortableGit-2.8.3-32-bit.7z.exe" # We choose the 32-bit version
        $downloadName = "PortableGit-2.8.3-32-bit.7z.exe"
        $expectedDownloadedFileHash = "DE52D070219E9C4EC1DB179F2ADBF4B760686C3180608F0382A1F8C7031E72AD"
        # There is another copy of git.exe in PortableGit\bin. However, an installed version of git add the cmd dir to the PATH.
        # Therefore, choosing the cmd dir here as well.
        $executableFromDownload = "$downloadsDir\PortableGit\cmd\git.exe"
        $extractionType = $ExtractionType_SELF_EXTRACTING_7Z
    }
    else
    {
        throw "Unknown program requested"
    }

    $downloadPath = "$downloadsDir\$downloadName"
    performDownload $Dependency $url $downloadsDir $downloadPath $downloadVersion $requiredVersion

    #calculating the hash
    $hashAlgorithm = [Security.Cryptography.HashAlgorithm]::Create("SHA256")
    $fileAsByteArray = [io.File]::ReadAllBytes($downloadPath)
    $hashByteArray = $hashAlgorithm.ComputeHash($fileAsByteArray)
    $downloadedFileHash = -Join ($hashByteArray | ForEach {"{0:x2}" -f $_})

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
            # Expand-Archive $downloadPath -dest "$downloadsDir" -Force # Requires powershell 5+
            Expand-ZIPFile -File $downloadPath -Destination $downloadsDir
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
}

SelectProgram $Dependency