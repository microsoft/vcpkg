
function Invoke-Download {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Url,
        [Parameter(Mandatory=$true)]
        [string]$OutputPath
    )
    Invoke-WebRequest -Uri $Url -OutFile $OutputPath -TimeoutSec 60 -ErrorAction Stop
}
function Invoke-Download-with-Check {
    param (
        [string]$Url,
        [string]$OutputPath,
        [string]$Check = "",
        [int]$ChunkSize = 1024
    )
    if ((Test-Path -Path $OutputPath) -and -not ([string]::IsNullOrWhiteSpace($Check))) {
        if ((Get-FileHash -Algorithm SHA256 -Path $OutputPath).Hash.ToLower() -eq $Check.ToLower()) {
            Write-Host "$OutputPath ... correct hash"
            return
        }
    }

    $response = Invoke-Download -Url $Url -OutputPath $OutputPath
    if (-not ([string]::IsNullOrWhiteSpace($Check))) {
        $digest = (Get-FileHash -Algorithm SHA256 -Path $OutputPath).Hash.ToLower() 
        if ($Check.ToLower() -ne $digest) {
            throw "Download failed: Hash mismatch for $OutputPath`nExpected: $($Check.ToLower())`nActual  : $digest"
        }
    }
}

function Get-SHA256Hash {
    param (
        [string]$File
    )
    $hashAlgorithm = [System.Security.Cryptography.SHA256]::Create()
    $fileStream = [System.IO.File]::OpenRead($File)
    $hashBytes = $hashAlgorithm.ComputeHash($fileStream)
    $fileStream.Close()
    return [BitConverter]::ToString($hashBytes).Replace("-", "").ToLower()
}

function VerifyHashOrRemoveFile {
    param (
        [string]$File,
        [string]$Hash
    )
    $calculatedHash = Get-SHA256Hash -File $File
    if ($calculatedHash -ne $Hash) {
        Write-Error "Hash mismatch for ${File}:`n `
         Expected: $Hash`n `
         Actual:   $calculatedHash`n"
        Remove-Item -Path $File -Force
        exit 1
    }
}
function Read-Json-from-File {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FilePath
    )
    $jsonContent = Get-Content -Path $FilePath -Raw
    return $jsonContent | ConvertFrom-Json
}

function Invoke-Download {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Url,
        [Parameter(Mandatory=$true)]
        [string]$OutputPath
    )
    Invoke-WebRequest -Uri $Url -OutFile $OutputPath -TimeoutSec 60 -ErrorAction Stop
}

function Invoke-Download-with-Check {
    param (
        [string]$Url,
        [string]$OutputPath,
        [string]$Check = "",
        [int]$ChunkSize = 1024
    )
    if ((Test-Path -Path $OutputPath) -and -not ([string]::IsNullOrWhiteSpace($Check))) {
        if ((Get-FileHash -Algorithm SHA256 -Path $OutputPath).Hash.ToLower() -eq $Check.ToLower()) {
            Write-Host "$OutputPath ... correct hash"
            return
        }
    }

    $response = Invoke-Download -Url $Url -OutputPath $OutputPath
    if (-not ([string]::IsNullOrWhiteSpace($Check))) {
        $digest = (Get-FileHash -Algorithm SHA256 -Path $OutputPath).Hash.ToLower() 
        if ($Check.ToLower() -ne $digest) {
            throw "Download failed: Hash mismatch for $OutputPath`nExpected: $($Check.ToLower())`nActual  : $digest"
        }
    }
}
