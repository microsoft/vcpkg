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

function vcpkgGetSHA512([Parameter(Mandatory=$true)][string]$filePath)
{
    if (vcpkgHasCommand -commandName 'Microsoft.PowerShell.Utility\Get-FileHash')
    {
        Write-Verbose("Hashing with Microsoft.PowerShell.Utility\Get-FileHash")
        $hashresult = Microsoft.PowerShell.Utility\Get-FileHash -Path $filePath -Algorithm SHA512 -ErrorVariable hashError
        if ($hashError)
        {
            Start-Sleep 3
            $hashresult = Microsoft.PowerShell.Utility\Get-FileHash -Path $filePath -Algorithm SHA512 -ErrorVariable Stop
        }
        $hash = $hashresult.Hash
    }
    elseif(vcpkgHasCommand -commandName 'Pscx\Get-Hash')
    {
        Write-Verbose("Hashing with Pscx\Get-Hash")
        $hash = (Pscx\Get-Hash -Path $filePath -Algorithm SHA512).HashString
    }
    else
    {
        Write-Verbose("Hashing with .NET")
        $hashAlgorithm = [Security.Cryptography.HashAlgorithm]::Create("SHA512")
        $fileAsByteArray = [io.File]::ReadAllBytes($filePath)
        $hashByteArray = $hashAlgorithm.ComputeHash($fileAsByteArray)
        $hash = -Join ($hashByteArray | ForEach-Object {"{0:x2}" -f $_})
    }

    return $hash.ToLower()
}

function vcpkgCheckEqualFileHash(   [Parameter(Mandatory=$true)][string]$url,
                                    [Parameter(Mandatory=$true)][string]$filePath,
                                    [Parameter(Mandatory=$true)][string]$expectedHash)
{
    $actualHash = vcpkgGetSHA512 $filePath
    if ($expectedHash -ne $actualHash)
    {
        Write-Host ("`nFile does not have expected hash:`n" +
        "              url: [ $url ]`n" +
        "        File path: [ $filePath ]`n" +
        "    Expected hash: [ $expectedHash ]`n" +
        "      Actual hash: [ $actualHash ]`n")
        throw
    }
}

function vcpkgDownloadFile( [Parameter(Mandatory=$true)][string]$url,
                            [Parameter(Mandatory=$true)][string]$downloadPath,
                            [Parameter(Mandatory=$true)][string]$sha512)
{
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
            Write-Warning "To solve this issue for future downloads, you can also install Windows Management Framework 5.1+"
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
    vcpkgCheckEqualFileHash -url $url -filePath $downloadPartPath -expectedHash $sha512
    Move-Item -Path $downloadPartPath -Destination $downloadPath
}

function vcpkgDownloadFileWithAria2(    [Parameter(Mandatory=$true)][string]$aria2exe,
                                        [Parameter(Mandatory=$true)][string]$url,
                                        [Parameter(Mandatory=$true)][string]$downloadPath,
                                        [Parameter(Mandatory=$true)][string]$sha512)
{
    vcpkgCreateParentDirectoryIfNotExists $downloadPath
    $downloadPartPath = "$downloadPath.part"
    vcpkgRemoveItem $downloadPartPath

    $parentDir = split-path -parent $downloadPath
    $filename = split-path -leaf $downloadPath

    if ((Test-Path $url) -or ($url.StartsWith("file://"))) # if is local file
    {
        vcpkgDownloadFile $url $downloadPath $sha512
        return
    }

    $ec = vcpkgInvokeCommand "$aria2exe" "--dir=`"$parentDir`" --out=`"$filename.part`" $url"
    if ($ec -ne 0)
    {
        Write-Host "Could not download $url"
        throw
    }

    vcpkgCheckEqualFileHash -url $url -filePath $downloadPartPath -expectedHash $sha512
    Move-Item -Path $downloadPartPath -Destination $downloadPath
}

function vcpkgExtractFileWith7z([Parameter(Mandatory=$true)][string]$sevenZipExe,
                                [Parameter(Mandatory=$true)][string]$archivePath,
                                [Parameter(Mandatory=$true)][string]$destinationDir)
{
    vcpkgRemoveItem $destinationDir
    $destinationPartial = "$destinationDir.partial"
    vcpkgRemoveItem $destinationPartial
    vcpkgCreateDirectoryIfNotExists $destinationPartial
    $ec = vcpkgInvokeCommand "$sevenZipExe" "x `"$archivePath`" -o`"$destinationPartial`" -y"
    if ($ec -ne 0)
    {
        Write-Host "Could not extract $archivePath"
        throw
    }
    Rename-Item -Path "$destinationPartial" -NewName $destinationDir -ErrorVariable renameResult
    if ($renameResult)
    {
        Start-Sleep 3
        Rename-Item -Path "$destinationPartial" -NewName $destinationDir -ErrorAction Stop
    }
}

function vcpkgExtractZipFile(  [Parameter(Mandatory=$true)][string]$archivePath,
                               [Parameter(Mandatory=$true)][string]$destinationDir)
{
    vcpkgRemoveItem $destinationDir
    $destinationPartial = "$destinationDir.partial"
    vcpkgRemoveItem $destinationPartial
    vcpkgCreateDirectoryIfNotExists $destinationPartial


    if (vcpkgHasCommand -commandName 'Microsoft.PowerShell.Archive\Expand-Archive')
    {
        Write-Verbose("Extracting with Microsoft.PowerShell.Archive\Expand-Archive")
        Microsoft.PowerShell.Archive\Expand-Archive -path $archivePath -destinationpath $destinationPartial
    }
    elseif (vcpkgHasCommand -commandName 'Pscx\Expand-Archive')
    {
        Write-Verbose("Extracting with Pscx\Expand-Archive")
        Pscx\Expand-Archive -path $archivePath -OutputPath $destinationPartial
    }
    else
    {
        Write-Verbose("Extracting via shell")
        $shell = new-object -com shell.application
        $zip = $shell.NameSpace($(Get-Item $archivePath).fullname)
        foreach($item in $zip.items())
        {
            # Piping to Out-Null is used to block until finished
            $shell.Namespace($destinationPartial).copyhere($item) | Out-Null
        }
    }

    Rename-Item -Path "$destinationPartial" -NewName $destinationDir
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
