function vcpkgHasModule([Parameter(Mandatory=$true)][string]$moduleName)
{
    return [bool](Get-Module -ListAvailable -Name $moduleName)
}

function vcpkgHasProperty([Parameter(Mandatory=$true)][AllowNull()]$object, [Parameter(Mandatory=$true)]$propertyName)
{
    if ($object -eq $null)
    {
        return $false
    }

    return [bool]($object.psobject.Properties | where { $_.Name -eq "$propertyName"})
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

function vcpkgIsDirectory([Parameter(Mandatory=$true)][string]$path)
{
    return (Get-Item $path) -is [System.IO.DirectoryInfo]
}

function vcpkgRemoveItem([Parameter(Mandatory=$true)][string]$path)
{
    if ([string]::IsNullOrEmpty($path))
    {
        return
    }

    if (Test-Path $path)
    {
        # Remove-Item -Recurse occasionally fails. This is a workaround
        if (vcpkgIsDirectory $path)
        {
            & cmd.exe /c rd /s /q $path
        }
        else
        {
            Remove-Item $path -Force
        }
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

function vcpkgDownloadFile( [Parameter(Mandatory=$true)][string]$url,
                            [Parameter(Mandatory=$true)][string]$downloadPath)
{
    if (Test-Path $downloadPath)
    {
        return
    }

    if ($url -match "github")
    {
        if ([System.Enum]::IsDefined([Net.SecurityProtocolType], "Tls12"))
        {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        }
        else
        {
            Write-Warning "Github has dropped support for TLS versions prior to 1.2, which is not available on your system"
            Write-Warning "Please manually download $url to $downloadPath"
            throw "Download failed"
        }
    }

    vcpkgCreateParentDirectoryIfNotExists $downloadPath

    $downloadPartPath = "$downloadPath.part"
    vcpkgRemoveItem $downloadPartPath


    $wc = New-Object System.Net.WebClient
    if (!$wc.Proxy.IsBypassed($url))
    {
        $wc.Proxy.Credentials = vcpkgGetCredentials
    }

    $wc.DownloadFile($url, $downloadPartPath)
    Move-Item -Path $downloadPartPath -Destination $downloadPath
}

function vcpkgExtractFile(  [Parameter(Mandatory=$true)][string]$file,
                            [Parameter(Mandatory=$true)][string]$destinationDir,
                            [Parameter(Mandatory=$true)][string]$outFilename)
{
    vcpkgCreateDirectoryIfNotExists $destinationDir
    $output = "$destinationDir\$outFilename"
    vcpkgRemoveItem $output
    $destinationPartial = "$destinationDir\partially-extracted"

    vcpkgRemoveItem $destinationPartial
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
        $zip = $shell.NameSpace($(Get-Item $file).fullname)
        foreach($item in $zip.items())
        {
            # Piping to Out-Null is used to block until finished
            $shell.Namespace($destinationPartial).copyhere($item) | Out-Null
        }
    }

    $itemCount = @(Get-ChildItem "$destinationPartial").Count

    if ($itemCount -eq 1)
    {
        Move-Item -Path "$destinationPartial\*" -Destination $output
        vcpkgRemoveItem $destinationPartial
    }
    else
    {
        Move-Item -Path "$destinationPartial" -Destination $output
    }
}

function vcpkgInvokeCommand()
{
    param ( [Parameter(Mandatory=$true)][string]$executable,
                                        [string]$arguments = "")

    Write-Verbose "Executing: ${executable} ${arguments}"
    $process = Start-Process -FilePath "`"$executable`"" -ArgumentList $arguments -PassThru -NoNewWindow
    Wait-Process -InputObject $process
    $ec = $process.ExitCode
    Write-Verbose "Execution terminated with exit code $ec."
    return $ec
}

function vcpkgInvokeCommandClean()
{
    param ( [Parameter(Mandatory=$true)][string]$executable,
                                        [string]$arguments = "")

    Write-Verbose "Clean-Executing: ${executable} ${arguments}"
    $scriptsDir = split-path -parent $script:MyInvocation.MyCommand.Definition
    $cleanEnvScript = "$scriptsDir\VcpkgPowershellUtils-ClearEnvironment.ps1"
    $tripleQuotes = "`"`"`""
    $argumentsWithEscapedQuotes = $arguments -replace "`"", $tripleQuotes
    $command = ". $tripleQuotes$cleanEnvScript$tripleQuotes; & $tripleQuotes$executable$tripleQuotes $argumentsWithEscapedQuotes"
    $arg = "-NoProfile", "-ExecutionPolicy Bypass", "-command $command"

    $process = Start-Process -FilePath powershell.exe -ArgumentList $arg -PassThru -NoNewWindow
    Wait-Process -InputObject $process
    $ec = $process.ExitCode
    Write-Verbose "Execution terminated with exit code $ec."
    return $ec
}

function vcpkgFormatElapsedTime([TimeSpan]$ts)
{
    if ($ts.TotalHours -ge 1)
    {
        return [string]::Format( "{0:N2} h", $ts.TotalHours);
    }

    if ($ts.TotalMinutes -ge 1)
    {
        return [string]::Format( "{0:N2} min", $ts.TotalMinutes);
    }

    if ($ts.TotalSeconds -ge 1)
    {
        return [string]::Format( "{0:N2} s", $ts.TotalSeconds);
    }

    if ($ts.TotalMilliseconds -ge 1)
    {
        return [string]::Format( "{0:N2} ms", $ts.TotalMilliseconds);
    }

    throw $ts
}

function vcpkgFindFileRecursivelyUp()
{
    param(
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory=$true)][string]$startingDir,
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory=$true)][string]$filename
    )

    $currentDir = $startingDir

    while (!($currentDir -eq "") -and !(Test-Path "$currentDir\$filename"))
    {
        Write-Verbose "Examining $currentDir for $filename"
        $currentDir = Split-path $currentDir -Parent
    }
    Write-Verbose "Examining $currentDir for $filename - Found"
    return $currentDir
}
