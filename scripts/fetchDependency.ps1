[CmdletBinding()]
param(
    [string]$Dependency,
    [ValidateNotNullOrEmpty()]
    [string]$downloadPromptOverride = "0"
)

$downloadPromptOverride_NO_OVERRIDE= 0
$downloadPromptOverride_DO_NOT_PROMPT = 1
$downloadPromptOverride_ALWAYS_PROMPT = 2

if ($PSVersionTable.PSEdition -ne "Core") {
   Import-Module BitsTransfer -Verbose:$false
}

Write-Verbose "Fetching dependency: $Dependency"

$scriptsDir = split-path -parent $MyInvocation.MyCommand.Definition
$vcpkgRootDir = & $scriptsDir\findFileRecursivelyUp.ps1 $scriptsDir .vcpkg-root

$downloadsDir = "$vcpkgRootDir\downloads"

function SelectProgram([Parameter(Mandatory=$true)][string]$Dependency)
{
    function promptForDownload([string]$title, [string]$message, [string]$yesDescription, [string]$noDescription, [string]$downloadPromptOverride)
    {
        $do_not_prompt =    ($downloadPromptOverride -eq $downloadPromptOverride_DO_NOT_PROMPT) -Or
                            (Test-Path "$downloadsDir\AlwaysAllowEverything") -Or
                            (Test-Path "$downloadsDir\AlwaysAllowDownloads")

        if (($downloadPromptOverride -ne $downloadPromptOverride_ALWAYS_PROMPT) -And $do_not_prompt)
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

        $userAllowedDownload = promptForDownload $title $message $yesDescription $noDescription $downloadPromptOverride
        if (!$userAllowedDownload)
        {
            throw [System.IO.FileNotFoundException] ("Could not detect suitable version of " + $Dependency + " and download not allowed")
        }

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
        $requiredVersion = "3.9.0"
        $downloadVersion = "3.9.0"
        $url = "https://cmake.org/files/v3.9/cmake-3.9.0-win32-x86.zip"
        $downloadPath = "$downloadsDir\cmake-3.9.0-win32-x86.zip"
        $expectedDownloadedFileHash = "9d593839f64b94718a1b75b8519b56ecb959e4d37d406bf2a087e2c1f7a6b89c"
        $executableFromDownload = "$downloadsDir\cmake-3.9.0-win32-x86\bin\cmake.exe"
        $extractionType = $ExtractionType_ZIP
        $extractionFolder = $downloadsDir
    }
    elseif($Dependency -eq "nuget")
    {
        $requiredVersion = "4.1.0"
        $downloadVersion = "4.1.0"
        $url = "https://dist.nuget.org/win-x86-commandline/v4.1.0/nuget.exe"
        $downloadPath = "$downloadsDir\nuget-4.1.0\nuget.exe"
        $expectedDownloadedFileHash = "4c1de9b026e0c4ab087302ff75240885742c0faa62bd2554f913bbe1f6cb63a0"
        $executableFromDownload = $downloadPath
        $extractionType = $ExtractionType_NO_EXTRACTION_REQUIRED
    }
    elseif($Dependency -eq "git")
    {
        $requiredVersion = "2.0.0"
        $downloadVersion = "2.11.1"
        $url = "https://github.com/git-for-windows/git/releases/download/v2.11.1.windows.1/MinGit-2.11.1-32-bit.zip" # We choose the 32-bit version
        $downloadPath = "$downloadsDir\MinGit-2.11.1-32-bit.zip"
        $expectedDownloadedFileHash = "6ca79af09015625f350ef4ad74a75cfb001b340aec095b6963be9d45becb3bba"
        # There is another copy of git.exe in MinGit\bin. However, an installed version of git add the cmd dir to the PATH.
        # Therefore, choosing the cmd dir here as well.
        $executableFromDownload = "$downloadsDir\MinGit-2.11.1-32-bit\cmd\git.exe"
        $extractionType = $ExtractionType_ZIP
        $extractionFolder = "$downloadsDir\MinGit-2.11.1-32-bit"
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
        $downloadedFileHash = -Join ($hashByteArray | ForEach {"{0:x2}" -f $_})
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
