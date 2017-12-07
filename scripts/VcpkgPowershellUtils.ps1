function vcpkgHasModule([Parameter(Mandatory=$true)][string]$moduleName)
{
    return [bool](Get-Module -ListAvailable -Name $moduleName)
}

function vcpkgCreateDirectoryIfNotExists([Parameter(Mandatory=$true)][string]$dirPath)
{
    if (!(Test-Path $dirPath))
    {
        New-Item -ItemType Directory -Path $dirPath | Out-Null
    }
}

function vcpkgCreateParentDirectoryIfNotExists([Parameter(Mandatory=$true)][string]$path)
{
    $parentDir = split-path -parent $path
    if ([string]::IsNullOrEmpty($parentDir))
    {
        return
    }

    if (!(Test-Path $parentDir))
    {
        New-Item -ItemType Directory -Path $parentDir | Out-Null
    }
}

function vcpkgRemoveDirectory([Parameter(Mandatory=$true)][string]$dirPath)
{
    if (Test-Path $dirPath)
    {
        Remove-Item $dirPath -Recurse -Force
    }
}

function vcpkgRemoveFile([Parameter(Mandatory=$true)][string]$filePath)
{
    if (Test-Path $filePath)
    {
        Remove-Item $filePath -Force
    }
}

function vcpkgHasCommand([Parameter(Mandatory=$true)][string]$commandName)
{
    return [bool](Get-Command -Name $commandName -ErrorAction SilentlyContinue)
}

function vcpkgHasCommandParameter([Parameter(Mandatory=$true)][string]$commandName, [Parameter(Mandatory=$true)][string]$parameterName)
{
    return (Get-Command $commandName).Parameters.Keys -contains $parameterName
}

function vcpkgGetCredentials()
{
    if (vcpkgHasCommandParameter -commandName 'Get-Credential' -parameterName 'Message')
    {
        return Get-Credential -Message "Enter credentials for Proxy Authentication"
    }
    else
    {
        Write-Host "Enter credentials for Proxy Authentication"
        return Get-Credential
    }
}

function vcpkgGetSHA256([Parameter(Mandatory=$true)][string]$filePath)
{
    if (vcpkgHasCommand -commandName 'Microsoft.PowerShell.Utility\Get-FileHash')
    {
        Write-Verbose("Hashing with Microsoft.PowerShell.Utility\Get-FileHash")
        $hash = (Microsoft.PowerShell.Utility\Get-FileHash -Path $filePath -Algorithm SHA256).Hash
    }
    elseif(vcpkgHasCommand -commandName 'Pscx\Get-Hash')
    {
        Write-Verbose("Hashing with Pscx\Get-Hash")
        $hash = (Pscx\Get-Hash -Path $filePath -Algorithm SHA256).HashString
    }
    else
    {
        Write-Verbose("Hashing with .NET")
        $hashAlgorithm = [Security.Cryptography.HashAlgorithm]::Create("SHA256")
        $fileAsByteArray = [io.File]::ReadAllBytes($filePath)
        $hashByteArray = $hashAlgorithm.ComputeHash($fileAsByteArray)
        $hash = -Join ($hashByteArray | ForEach-Object {"{0:x2}" -f $_})
    }

    return $hash.ToLower()
}

function vcpkgCheckEqualFileHash(   [Parameter(Mandatory=$true)][string]$filePath,
                                    [Parameter(Mandatory=$true)][string]$expectedHash,
                                    [Parameter(Mandatory=$true)][string]$actualHash )
{
    if ($expectedDownloadedFileHash -ne $downloadedFileHash)
    {
        Write-Host ("`nFile does not have expected hash:`n" +
        "        File path: [ $filePath ]`n" +
        "    Expected hash: [ $expectedHash ]`n" +
        "      Actual hash: [ $actualHash ]`n")
        throw "Invalid Hash for file $filePath"
    }
}

if (vcpkgHasModule -moduleName 'BitsTransfer')
{
   Import-Module BitsTransfer -Verbose:$false
}

function vcpkgDownloadFile( [Parameter(Mandatory=$true)][string]$url,
                            [Parameter(Mandatory=$true)][string]$downloadPath)
{
    if (Test-Path $downloadPath)
    {
        return
    }

    vcpkgCreateParentDirectoryIfNotExists $downloadPath

    $downloadPartPath = "$downloadPath.part"
    vcpkgRemoveFile $downloadPartPath

    $wc = New-Object System.Net.WebClient
    $proxyAuth = !$wc.Proxy.IsBypassed($url)
    if ($proxyAuth)
    {
        $wc.Proxy.Credentials = vcpkgGetCredentials
    }

    # Some download (e.g. git from github)fail with Start-BitsTransfer
    if (vcpkgHasCommand -commandName 'Start-BitsTransfer')
    {
        try
        {
            if ($proxyAuth)
            {
                $PSDefaultParameterValues.Add("Start-BitsTransfer:ProxyAuthentication","Basic")
                $PSDefaultParameterValues.Add("Start-BitsTransfer:ProxyCredential", $wc.Proxy.Credentials)
            }
            Start-BitsTransfer -Source $url -Destination $downloadPartPath -ErrorAction Stop
            Move-Item -Path $downloadPartPath -Destination $downloadPath
            return
        }
        catch [System.Exception]
        {
            # If BITS fails for any reason, delete any potentially partially downloaded files and continue
            vcpkgRemoveFile $downloadPartPath
        }
    }

    Write-Verbose("Downloading $Dependency...")
    $wc.DownloadFile($url, $downloadPartPath)
    Move-Item -Path $downloadPartPath -Destination $downloadPath
}

function vcpkgExtractFile(  [Parameter(Mandatory=$true)][string]$file,
                            [Parameter(Mandatory=$true)][string]$destinationDir)
{
    vcpkgCreateParentDirectoryIfNotExists $destinationDir
    $destinationPartial = "$destinationDir-partially_extracted"

    vcpkgRemoveDirectory $destinationPartial
    vcpkgCreateDirectoryIfNotExists $destinationPartial

    if (vcpkgHasCommand -commandName 'Microsoft.PowerShell.Archive\Expand-Archive')
    {
        Write-Verbose("Extracting with Microsoft.PowerShell.Archive\Expand-Archive")
        Microsoft.PowerShell.Archive\Expand-Archive -path $file -destinationpath $destinationPartial
    }
    elseif (vcpkgHasCommand -commandName 'Pscx\Expand-Archive')
    {
        Write-Verbose("Extracting with Pscx\Expand-Archive")
        Pscx\Expand-Archive -path $file -OutputPath $destinationPartial
    }
    else
    {
        Write-Verbose("Extracting via shell")
        $shell = new-object -com shell.application
        $zip = $shell.NameSpace($file)
        foreach($item in $zip.items())
        {
            # Piping to Out-Null is used to block until finished
            $shell.Namespace($destinationPartial).copyhere($item) | Out-Null
        }
    }

    $hasASingleItem = (Get-ChildItem $destinationPartial | Measure-Object).Count -eq 1;

    if ($hasASingleItem)
    {
        Move-Item -Path "$destinationPartial\*" -Destination $destinationDir
        vcpkgRemoveDirectory $destinationPartial
    }
    else
    {
        Move-Item -Path $destinationPartial -Destination $destinationDir
    }
}

function vcpkgInvokeCommand()
{
    param ( [Parameter(Mandatory=$true)][string]$executable,
                                        [string]$arguments = "",
                                        [switch]$wait)

    Write-Verbose "Executing: ${executable} ${arguments}"
    $process = Start-Process -FilePath $executable -ArgumentList $arguments -PassThru
    if ($wait)
    {
        Wait-Process -InputObject $process
        $ec = $process.ExitCode
        Write-Verbose "Execution terminated with exit code $ec."
    }
}