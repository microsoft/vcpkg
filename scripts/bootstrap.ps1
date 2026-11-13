[CmdletBinding()]
param(
    $badParam,
    [Parameter(Mandatory=$False)][switch]$win64 = $false,
    [Parameter(Mandatory=$False)][string]$withVSPath = "",
    [Parameter(Mandatory=$False)][string]$withWinSDK = "",
    [Parameter(Mandatory=$False)][switch]$disableMetrics = $false
)
Set-StrictMode -Version Latest
# Powershell2-compatible way of forcing named-parameters
if ($badParam)
{
    if ($disableMetrics -and $badParam -eq "1")
    {
        Write-Warning "'disableMetrics 1' is deprecated, please change to 'disableMetrics' (without '1')."
    }
    else
    {
        throw "Only named parameters are allowed."
    }
}

if ($win64)
{
    Write-Warning "-win64 no longer has any effect; ignored."
}

if (-Not [string]::IsNullOrWhiteSpace($withVSPath))
{
    Write-Warning "-withVSPath no longer has any effect; ignored."
}

if (-Not [string]::IsNullOrWhiteSpace($withWinSDK))
{
    Write-Warning "-withWinSDK no longer has any effect; ignored."
}

$scriptsDir = split-path -parent $script:MyInvocation.MyCommand.Definition
$vcpkgRootDir = $scriptsDir
while (!($vcpkgRootDir -eq "") -and !(Test-Path "$vcpkgRootDir\.vcpkg-root"))
{
    Write-Verbose "Examining $vcpkgRootDir for .vcpkg-root"
    $vcpkgRootDir = Split-path $vcpkgRootDir -Parent
}

Write-Verbose "Examining $vcpkgRootDir for .vcpkg-root - Found"

# Read the vcpkg-tool config file to determine what release to download
$Config = ConvertFrom-StringData (Get-Content "$PSScriptRoot\vcpkg-tool-metadata.txt" -Raw)
$versionDate = $Config.VCPKG_TOOL_RELEASE_TAG

# Only used by the Windows PowerShell/.NET Framework fallback. PowerShell 6+
# returns before calling this helper and lets modern .NET handle NO_PROXY.
function ConvertTo-LegacyWebProxyBypassList
{
    param([string]$NoProxy)

    # Modern .NET handles NO_PROXY directly and does not need regex conversion.
    if ($PSVersionTable.PSVersion.Major -ge 6)
    {
        return @()
    }

    # .NET Framework's WebProxy.BypassList expects regular expressions instead
    # of the host patterns used by NO_PROXY.
    $bypassPatterns = @()
    foreach ($entry in ($NoProxy -split '[,;]'))
    {
        $entry = $entry.Trim()
        if ([string]::IsNullOrEmpty($entry))
        {
            continue
        }

        if ($entry -eq '*')
        {
            $bypassPatterns += '.*'
            continue
        }

        if ($entry -ieq '<local>')
        {
            $bypassPatterns += '(?i)^https?://[^./:]+(?::\d+)?(/|$)'
            continue
        }

        $entry = $entry -replace '^https?://', ''
        $proxyPort = ''
        if ($entry -match '^\[([^\]]+)\](?::(\d+))?$')
        {
            $hostName = '[' + $matches[1] + ']'
            $proxyPort = $matches[2]
            $hostPrefix = ''
        }
        else
        {
            if ($entry -match '^([^:]+):(\d+)$')
            {
                $hostName = $matches[1]
                $proxyPort = $matches[2]
            }
            else
            {
                $hostName = $entry
            }

            if ($hostName.StartsWith('*.'))
            {
                $hostName = $hostName.Substring(2)
                $hostPrefix = '(?:[^/]+\.)+'
            }
            else
            {
                if ($hostName.StartsWith('.'))
                {
                    $hostName = $hostName.Substring(1)
                }
                $hostPrefix = '(?:[^/]+\.)?'
            }
        }

        $hostPattern = [regex]::Escape($hostName).Replace('\*', '[^/]*')
        if ($proxyPort -eq '443')
        {
            # Uri normalizes an explicit HTTPS default port away.
            $bypassPatterns += '(?i)^https://' + $hostPrefix + $hostPattern + '(?::443)?(/|$)'
            $bypassPatterns += '(?i)^http://' + $hostPrefix + $hostPattern + ':443(/|$)'
        }
        elseif ($proxyPort -eq '80')
        {
            # Uri normalizes an explicit HTTP default port away.
            $bypassPatterns += '(?i)^http://' + $hostPrefix + $hostPattern + '(?::80)?(/|$)'
            $bypassPatterns += '(?i)^https://' + $hostPrefix + $hostPattern + ':80(/|$)'
        }
        elseif ([string]::IsNullOrEmpty($proxyPort))
        {
            $portPattern = '(?::\d+)?'
            $bypassPatterns += '(?i)^https?://' + $hostPrefix + $hostPattern + $portPattern + '(/|$)'
        }
        else
        {
            $portPattern = ':' + [regex]::Escape($proxyPort)
            $bypassPatterns += '(?i)^https?://' + $hostPrefix + $hostPattern + $portPattern + '(/|$)'
        }
    }

    return $bypassPatterns
}

function New-BootstrapWebClient
{
    $webClient = New-Object System.Net.WebClient

    # Modern .NET reads HTTPS_PROXY and NO_PROXY through its default proxy.
    # Windows PowerShell/.NET Framework does not, so keep the explicit bridge
    # below for the bootstrap's legacy PowerShell entry point.
    if ($PSVersionTable.PSVersion.Major -ge 6)
    {
        return $webClient
    }

    $systemProxy = [System.Net.WebRequest]::DefaultWebProxy
    if ($null -ne $systemProxy)
    {
        $webClient.Proxy = $systemProxy
        if ($systemProxy -is [System.Net.WebProxy])
        {
            $systemProxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
        }
    }

    if ([string]::IsNullOrEmpty($env:HTTPS_PROXY))
    {
        return $webClient
    }

    try
    {
        $proxyAddress = $env:HTTPS_PROXY.Trim()
        $proxyUri = $null
        $proxyUriIsValid = [System.Uri]::TryCreate($proxyAddress, [System.UriKind]::Absolute, [ref]$proxyUri)
        if (-Not $proxyUriIsValid -or $null -eq $proxyUri -or [string]::IsNullOrEmpty($proxyUri.Host))
        {
            $proxyUri = $null
            $proxyUriIsValid = [System.Uri]::TryCreate("http://$proxyAddress", [System.UriKind]::Absolute, [ref]$proxyUri)
        }
        if (-Not $proxyUriIsValid -or $null -eq $proxyUri -or [string]::IsNullOrEmpty($proxyUri.Host))
        {
            throw "The HTTPS_PROXY value is not a valid proxy URI."
        }

        $proxyUserInfo = $proxyUri.UserInfo
        $proxyUriBuilder = New-Object -TypeName System.UriBuilder -ArgumentList $proxyUri
        $proxyUriBuilder.UserName = ""
        $proxyUriBuilder.Password = ""
        $proxy = New-Object -TypeName System.Net.WebProxy -ArgumentList $proxyUriBuilder.Uri

        if (-Not [string]::IsNullOrEmpty($env:NO_PROXY))
        {
            $bypassList = @(ConvertTo-LegacyWebProxyBypassList -NoProxy $env:NO_PROXY)
            if ($bypassList.Count -gt 0)
            {
                $proxy.BypassList = [string[]]$bypassList
            }
        }

        if ([string]::IsNullOrEmpty($proxyUserInfo))
        {
            $proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
        }
        else
        {
            $proxyCredentials = [System.Uri]::UnescapeDataString($proxyUserInfo)
            $separator = $proxyCredentials.IndexOf(':')
            if ($separator -lt 0)
            {
                $proxyUserName = $proxyCredentials
                $proxyPassword = ""
            }
            else
            {
                $proxyUserName = $proxyCredentials.Substring(0, $separator)
                $proxyPassword = $proxyCredentials.Substring($separator + 1)
            }
            $proxy.Credentials = New-Object -TypeName System.Net.NetworkCredential -ArgumentList @($proxyUserName, $proxyPassword)
        }

        $webClient.Proxy = $proxy
    }
    catch
    {
        # WebClient retains the Windows proxy configuration unless the environment proxy is usable.
        Write-Warning "Could not configure HTTPS_PROXY; falling back to Windows proxy settings."
    }

    return $webClient
}

function Invoke-DownloadWithRetry
{
    param(
        [Parameter(Mandatory=$true)][string]$Url,
        [Parameter(Mandatory=$true)][string]$OutFile
    )

    # Prefer the named enum member when this .NET runtime provides it. Older
    # .NET Framework versions can still accept TLS 1.2 through its numeric value.
    if ([System.Enum]::IsDefined([System.Net.SecurityProtocolType], 'Tls12'))
    {
        $tls12Protocol = [System.Net.SecurityProtocolType]::Tls12
    }
    else
    {
        $tls12Protocol = [System.Net.SecurityProtocolType]3072
    }

    $currentSecurityProtocols = [int][System.Net.ServicePointManager]::SecurityProtocol
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]($currentSecurityProtocols -bor [int]$tls12Protocol)

    $tempFile = "$OutFile.part"
    Remove-Item -Path $tempFile -ErrorAction SilentlyContinue

    $maxAttempts = 3
    for ($attempt = 1; $attempt -le $maxAttempts; $attempt++)
    {
        try
        {
            $webClient = New-BootstrapWebClient
            try
            {
                $webClient.DownloadFile($Url, $tempFile)
            }
            finally
            {
                $webClient.Dispose()
            }

            # Match tls12-download.exe: only promote a download with a valid
            # Authenticode signature.
            $signature = Get-AuthenticodeSignature -FilePath $tempFile -ErrorAction Stop
            if ($signature.Status -ne 'Valid')
            {
                throw "Downloaded vcpkg.exe has an invalid Authenticode signature (status: $($signature.Status))."
            }

            Move-Item -Path $tempFile -Destination $OutFile -Force -ErrorAction Stop
            return $true
        }
        catch
        {
            Write-Warning "Attempt $attempt of $maxAttempts to download '$Url' failed: $_"
            Remove-Item -Path $tempFile -ErrorAction SilentlyContinue
            if ($attempt -lt $maxAttempts)
            {
                Start-Sleep -Seconds 1
            }
        }
    }

    return $false
}

if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64' -or $env:PROCESSOR_IDENTIFIER -match "ARMv[8,9] \(64-bit\)") {
    $vcpkgToolUrl = "https://github.com/microsoft/vcpkg-tool/releases/download/$versionDate/vcpkg-arm64.exe"
} else {
    $vcpkgToolUrl = "https://github.com/microsoft/vcpkg-tool/releases/download/$versionDate/vcpkg.exe"
}

$downloadSucceeded = Invoke-DownloadWithRetry -Url $vcpkgToolUrl -OutFile "$vcpkgRootDir\vcpkg.exe"

Write-Host ""

if (-not $downloadSucceeded)
{
    Write-Error "Downloading vcpkg.exe failed. Please check your internet connection, or consider downloading a recent vcpkg.exe from https://github.com/microsoft/vcpkg-tool with a browser."
    throw
}

& "$vcpkgRootDir\vcpkg.exe" version --disable-metrics

if ($disableMetrics)
{
    Set-Content -Value "" -Path "$vcpkgRootDir\vcpkg.disable-metrics" -Force
}
elseif (-Not (Test-Path "$vcpkgRootDir\vcpkg.disable-metrics"))
{
    # Note that we intentionally leave any existing vcpkg.disable-metrics; once a user has
    # opted out they should stay opted out.
    Write-Host @"
Telemetry
---------
vcpkg collects usage data in order to help us improve your experience.
The data collected by Microsoft is anonymous.
You can opt-out of telemetry by re-running the bootstrap-vcpkg script with -disableMetrics,
passing --disable-metrics to vcpkg on the command line,
or by setting the VCPKG_DISABLE_METRICS environment variable.

Read more about vcpkg telemetry at https://learn.microsoft.com/vcpkg/about/privacy
Read the Microsoft Privacy Statement at https://go.microsoft.com/fwlink/?LinkId=521839
"@
}
