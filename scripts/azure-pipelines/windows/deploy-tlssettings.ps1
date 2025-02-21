#***************************************************************************************************************
# This script supports the TLS 1.2 everywhere project
# It does the following:
#   *   By default it disables TLS 1.O, TLS 1.1, SSLv2, SSLv3 and Enables TLS1.2
#   *   The CipherSuite order is set to the SDL approved version.
#   *   The FIPS MinEncryptionLevel is set to 3.
#   *   RC4 is disabled
#   *   A log with a transcript of all actions taken is generated
#***************************************************************************************************************

#************************************************ SCRIPT USAGE  ************************************************
# .\TLSSettings.ps1
#   -SetCipherOrder         :   Excellence/Min-Bar, default(Excellence), use B to set Min-Bar. (Min-Bar ordering prefers ciphers with smaller key sizes to improve performance over security)
#   -RebootIfRequired       :   $true/$false, default($true), use $false to disable auto-reboot (Settings won't take effect until a reboot is completed)
#   -EnableOlderTlsVersions :   $true/$false, default($false), use $true to explicitly Enable TLS1.0, TLS1.1
#***************************************************************************************************************

#***************************TEAM CAN DETERMINE WHAT CIPHER SUITE ORDER IS CHOSEN  ******************************
# Option B provides the min-bar configuration (small trade-off: performance over security)
# Syntax:     .\TLSSettings.ps1 -SetCipherOrder B 
# if no option is supplied, you will get the opportunity for excellence cipher order (small trade-off: security over performance)
# Syntax:     .\TLSSettings.ps1 
#***************************************************************************************************************

param (
    [string]$SetCipherOrder = " ", 
    [bool]$RebootIfRequired = $true,
    [bool]$EnableOlderTlsVersions = $false
)

#******************* FUNCTION THAT ACTUALLY UPDATES KEYS; WILL RETURN REBOOT FLAG IF CHANGES ***********************
Function Set-CryptoSetting { 
    param ( 
        $regKeyName, 
        $value, 
        $valuedata, 
        $valuetype      
    ) 
 
    $restart = $false
 
    # Check for existence of registry key, and create if it does not exist 
    If (!(Test-Path -Path $regKeyName)) { 
        New-Item $regKeyName | Out-Null 
    } 
 
 
    # Get data of registry value, or null if it does not exist 
    $val = (Get-ItemProperty -Path $regKeyName -Name $value -ErrorAction SilentlyContinue).$value 
 
 
    If ($val -eq $null) { 
        # Value does not exist - create and set to desired value 
        New-ItemProperty -Path $regKeyName -Name $value -Value $valuedata -PropertyType $valuetype | Out-Null 
        $restart = $true
    }
    Else { 
        # Value does exist - if not equal to desired value, change it 
        If ($val -ne $valuedata) { 
            Set-ItemProperty -Path $regKeyName -Name $value -Value $valuedata 
            $restart = $true 
        } 
    } 
 
 	
    $restart 
} 
#***************************************************************************************************************

 
#******************* FUNCTION THAT DISABLES RC4 *********************** 
Function DisableRC4 { 
   
    $restart = $false
    $subkeys = Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL" 
    $ciphers = $subkeys.OpenSubKey("Ciphers", $true) 
 
    Write-Log -Message "----- Checking the status of RC4 -----"  -Logfile $logLocation -Severity Information
   
    $RC4 = $false
    if ($ciphers.SubKeyCount -eq 0) { 
        $k1 = $ciphers.CreateSubKey("RC4 128/128") 
        $k1.SetValue("Enabled", 0, [Microsoft.Win32.RegistryValueKind]::DWord) 
        $restart = $true 
        $k2 = $ciphers.CreateSubKey("RC4 64/128") 
        $k2.SetValue("Enabled", 0, [Microsoft.Win32.RegistryValueKind]::DWord) 
        $k3 = $ciphers.CreateSubKey("RC4 56/128") 
        $k3.SetValue("Enabled", 0, [Microsoft.Win32.RegistryValueKind]::DWord) 
        $k4 = $ciphers.CreateSubKey("RC4 40/128") 
        $k4.SetValue("Enabled", 0, [Microsoft.Win32.RegistryValueKind]::DWord) 
	 	 
        Write-Log -Message "RC4 was disabled "  -Logfile $logLocation -Severity Information
        $RC4 = $true
    } 
   
    If ($RC4 -ne $true) {
        Write-Log -Message "There was no change for RC4 "  -Logfile $logLocation -Severity Information
    }
 
    $restart 
} 
#***************************************************************************************************************

#******************* FUNCTION CHECKS FOR PROBLEMATIC FIPS SETTING AND FIXES IT  ***********************
Function Test-RegistryValueForFipsSettings { 
    
    $restart = $false
    		
    $fipsPath = @( 
        "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp",
        "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services",
        "HKLM:\System\CurrentControlSet\Control\Terminal Server\DefaultUserConfiguration"
    )
	
    $fipsValue = "MinEncryptionLevel"
	
	
    foreach ($path in $fipsPath) {

        Write-Log -Message "Checking to see if $($path)\$fipsValue exists"  -Logfile $logLocation -Severity Information

        $ErrorActionPreference = "stop"
        Try {
		
            $result = Get-ItemProperty -Path $path | Select-Object -ExpandProperty $fipsValue
            if ($result -eq 4) {
                set-itemproperty -Path $path -Name $fipsValue -value 3
                Write-Log -Message "Regkey $($path)\$fipsValue was changed from value $result to a value of 3"  -Logfile $logLocation -Severity Information
                $restart = $true
            }
			else {
                Write-Log -Message "Regkey $($path)\$fipsValue left at value $result"  -Logfile $logLocation -Severity Information
			}
	
        }
        Catch [System.Management.Automation.ItemNotFoundException] {
        	
            Write-Log -Message "Reg path $path was not found" -Logfile $logLocation  -Severity Information
        }
        Catch [System.Management.Automation.PSArgumentException] {
		
            Write-Log -Message "Regkey $($path)\$fipsValue was not found" -Logfile $logLocation  -Severity Information
        }
        Catch {
            Write-Log -Message "Error of type $($Error[0].Exception.GetType().FullName) trying to get $($path)\$fipsValue"  -Logfile $logLocation -Severity Information
        }
        Finally {$ErrorActionPreference = "Continue"
        }
    }	
    $restart 
} 
#***************************************************************************************************************
 
#********************************** FUNCTION THAT CREATE LOG DIRECTORY IF IT DOES NOT EXIST *******************************
function CreateLogDirectory { 	
    
    $TARGETDIR = "$env:HOMEDRIVE\Logs"
    if ( -Not (Test-Path -Path $TARGETDIR ) ) {
        New-Item -ItemType directory -Path $TARGETDIR | Out-Null
    }
   
   $TARGETDIR = $TARGETDIR + "\" + "TLSSettingsLogFile.csv"

   return $TARGETDIR
}
#***************************************************************************************************************


#********************************** FUNCTION THAT LOGS WHAT THE SCRIPT IS DOING *******************************
function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$LogFile,
 
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Information', 'Warning', 'Error')]
        [string]$Severity = 'Information'
    )

     
    [pscustomobject]@{
        Time     = (Get-Date -f g)
        Message  = $Message
        Severity = $Severity
    } | ConvertTo-Csv -NoTypeInformation | Select-Object -Skip 1 | Out-File -Append -FilePath $LogFile
}

#********************************TLS CipherSuite Settings *******************************************

# CipherSuites for windows OS < 10
function Get-BaseCipherSuitesOlderWindows()
{
    param
    (
        [Parameter(Mandatory=$true, Position=0)][bool] $isExcellenceOrder
    )
    $cipherorder = @()

    if ($isExcellenceOrder -eq $true)
    {
        $cipherorder += "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384_P384"
        $cipherorder += "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256_P256"
        $cipherorder += "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384_P384"
        $cipherorder += "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256_P256"
        $cipherorder += "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384_P384"
        $cipherorder += "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256_P256"
    }
    else
    {
        $cipherorder += "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256_P256"
        $cipherorder += "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384_P384"
        $cipherorder += "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256_P256"
        $cipherorder += "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384_P384"
        $cipherorder += "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256_P256"
        $cipherorder += "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384_P384"
    }

    # Add additional ciphers when EnableOlderTlsVersions flag is set to true
    if ($EnableOlderTlsVersions)
    {
        $cipherorder += "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA_P256"
        $cipherorder += "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA_P256"
        $cipherorder += "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA_P256"
        $cipherorder += "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA_P256"
        $cipherorder += "TLS_RSA_WITH_AES_256_GCM_SHA384" 
        $cipherorder += "TLS_RSA_WITH_AES_128_GCM_SHA256" 
        $cipherorder += "TLS_RSA_WITH_AES_256_CBC_SHA256" 
        $cipherorder += "TLS_RSA_WITH_AES_128_CBC_SHA256" 
        $cipherorder += "TLS_RSA_WITH_AES_256_CBC_SHA"
        $cipherorder += "TLS_RSA_WITH_AES_128_CBC_SHA"
    }
    return $cipherorder
}

# Ciphersuites needed for backwards compatibility with Firefox, Chrome
# Server 2012 R2 doesn't support TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
# Both firefox and chrome negotiate ECDHE_RSA_AES_256_CBC_SHA1, Edge negotiates ECDHE_RSA_AES_256_CBC_SHA384
function Get-BrowserCompatCipherSuitesOlderWindows()
{
    param
    (
        [Parameter(Mandatory=$true, Position=0)][bool] $isExcellenceOrder
    )
    $cipherorder = @()

    if ($isExcellenceOrder -eq $true)
    {
        $cipherorder += "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA_P384"  # (uses SHA-1)  
        $cipherorder += "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA_P256"  # (uses SHA-1)
    }
    else
    {
        $cipherorder += "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA_P256"  # (uses SHA-1)
        $cipherorder += "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA_P384"  # (uses SHA-1)  
    }
    return $cipherorder
}

# Ciphersuites for OS versions windows 10 and above
function Get-BaseCipherSuitesWin10Above()
{
    param
    (
        [Parameter(Mandatory=$true, Position=0)][bool] $isExcellenceOrder
    )

    $cipherorder = @()

    if ($isExcellenceOrder -eq $true)
    {
        
        $cipherorder += "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384"
        $cipherorder += "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
        $cipherorder += "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"
        $cipherorder += "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
        $cipherorder += "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384"
        $cipherorder += "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256"
        $cipherorder += "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384"
        $cipherorder += "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256"
    }
    else
    {
        $cipherorder += "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
        $cipherorder += "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384"
        $cipherorder += "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
        $cipherorder += "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"
        $cipherorder += "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256"
        $cipherorder += "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384"
        $cipherorder += "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256"
        $cipherorder += "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384"
    }
    # Add additional ciphers when EnableOlderTlsVersions flag is set to true
    if ($EnableOlderTlsVersions)
    {
        $cipherorder += "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA_P256"
        $cipherorder += "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA_P256"
        $cipherorder += "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA_P256"
        $cipherorder += "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA_P256"
        $cipherorder += "TLS_RSA_WITH_AES_256_GCM_SHA384" 
        $cipherorder += "TLS_RSA_WITH_AES_128_GCM_SHA256" 
        $cipherorder += "TLS_RSA_WITH_AES_256_CBC_SHA256" 
        $cipherorder += "TLS_RSA_WITH_AES_128_CBC_SHA256" 
        $cipherorder += "TLS_RSA_WITH_AES_256_CBC_SHA"
        $cipherorder += "TLS_RSA_WITH_AES_128_CBC_SHA"
    }

    return $cipherorder
}


#******************************* TLS Version Settings ****************************************************

function Get-RegKeyPathForTls12()
{
    $regKeyPath = @(
        "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2",        
        "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client", 
        "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" 
    )
    return $regKeyPath
}

function Get-RegKeyPathForTls11()
{
    $regKeyPath = @(
        "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1", 
        "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client",
        "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" 
    )
    return $regKeyPath
}

function Get-RegKeypathForTls10()
{
    $regKeyPath = @(
        "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0", 
        "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client", 
        "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server"
    )
    return $regKeyPath
}

function Get-RegKeyPathForSsl30()
{
    $regKeyPath = @(
        "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0",        
        "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client", 
        "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server"
    )
    return $regKeyPath
}

function Get-RegKeyPathForSsl20()
{
    $regKeyPath = @(
        "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0",
        "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Client",  
        "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server"
    )
    return $regKeyPath
}

#Initialize reboot value to false
$reboot = $false

#*****************************Create the logfile if not does not exist*************************************** 
$logLocation = CreateLogDirectory  

 
#Start writing to the logs
Write-Log -Message "========== Start of logging for a script execution =========="  -Logfile $logLocation -Severity Information

$registryPathGoodGuys = @()
$registryPathBadGuys = @()

# we enable TLS 1.2 and disable SSL 2.0, 3.0 in any case
$registryPathGoodGuys += Get-RegKeyPathForTls12

$registryPathBadGuys += Get-RegKeyPathForSsl20
$registryPathBadGuys += Get-RegKeyPathForSsl30

# add TLS 1.0/1.1 to good/bad depending on user's preference
# default is adding TLS 1.0/1.1 to bad
if ($EnableOlderTlsVersions)
{
    $registryPathGoodGuys += Get-RegKeypathForTls10
    $registryPathGoodGuys += Get-RegKeyPathForTls11
    Write-Log -Message "Enabling TLS1.2, TLS1.1, TLS1.0. Disabling SSL3.0, SSL2.0"  -Logfile $logLocation -Severity Information
}
else
{
    $registryPathBadGuys += Get-RegKeypathForTls10
    $registryPathBadGuys += Get-RegKeyPathForTls11
    Write-Log -Message "Enabling TLS1.2. Disabling TLS1.1, TLS1.0, SSL3.0, SSL2.0"  -Logfile $logLocation -Severity Information
}


Write-Log -Message "Check which registry keys exist already and which registry keys need to be created."  -Logfile $logLocation -Severity Information 

#******************* CREATE THE REGISTRY KEYS IF THEY DON'T EXIST********************************
# Check for existence of GoodGuy registry keys, and create if they do not exist 
For ($i = 0; $i -lt $registryPathGoodGuys.Length; $i = $i + 1) { 
 	   	   
	   Write-Log -Message "Checking for existing of key: $($registryPathGoodGuys[$i]) " -Logfile $logLocation  -Severity Information
	   If (!(Test-Path -Path $registryPathGoodGuys[$i])) { 
        New-Item $registryPathGoodGuys[$i] | Out-Null
     	  Write-Log -Message "Creating key: $($registryPathGoodGuys[$i]) "  -Logfile $logLocation -Severity Information
 	  }
} 
 
# Check for existence of BadGuy registry keys, and create if they do not exist 
For ($i = 0; $i -lt $registryPathBadGuys.Length; $i = $i + 1) { 
 
    Write-Log -Message "Checking for existing of key: $($registryPathBadGuys[$i]) "  -Logfile $logLocation -Severity Information
	   If (!(Test-Path -Path $registryPathBadGuys[$i])) { 
        Write-Log -Message "Creating key: $($registryPathBadGuys[$i]) "  -Logfile $logLocation -Severity Information
        New-Item  $registryPathBadGuys[$i] | Out-Null
 	  }
}
 
#******************* EXPLICITLY DISABLE SSLV2, SSLV3, TLS10 AND TLS11 ********************************
For ($i = 0; $i -lt $registryPathBadGuys.Length; $i = $i + 1) {
   
    if ($registryPathBadGuys[$i].Contains("Client") -Or $registryPathBadGuys[$i].Contains("Server")) {
 
        Write-Log -Message "Disabling this key: $($registryPathBadGuys[$i]) "  -Logfile $logLocation -Severity Information
        $result = Set-CryptoSetting $registryPathBadGuys[$i].ToString() Enabled 0 DWord  
        $result = Set-CryptoSetting $registryPathBadGuys[$i].ToString() DisabledByDefault 1 DWord  
        $reboot = $reboot -or $result
    }
}
 
#********************************* EXPLICITLY Enable TLS12 ****************************************
For ($i = 0; $i -lt $registryPathGoodGuys.Length; $i = $i + 1) {
 	
    if ($registryPathGoodGuys[$i].Contains("Client") -Or $registryPathGoodGuys[$i].Contains("Server")) {
	
        Write-Log -Message "Enabling this key: $($registryPathGoodGuys[$i]) "  -Logfile $logLocation -Severity Information 
        $result = Set-CryptoSetting $registryPathGoodGuys[$i].ToString() Enabled 1 DWord  
        $result = Set-CryptoSetting $registryPathGoodGuys[$i].ToString() DisabledByDefault 0 DWord 
        $reboot = $reboot -or $result
    }
}
 
#************************************** Disable RC4 ************************************************ 
$result = DisableRC4
$reboot = $reboot -or $result
 
  
#************************************** Set Cipher Suite Order **************************************
Write-Log -Message "----- starting ciphersuite order calculation -----"  -Logfile $logLocation -Severity Information 
$configureExcellenceOrder = $true
if ($SetCipherOrder.ToUpper() -eq "B")
{
    $configureExcellenceOrder = $false
    Write-Host "The min bar cipher suite order was chosen."
    Write-Log -Message "The min bar cipher suite order was chosen."  -Logfile $logLocation -Severity Information
}
else
{
    Write-Host "The opportunity for excellence cipher suite order was chosen."
    Write-Log -Message "The opportunity for excellence cipher suite order was chosen."  -Logfile $logLocation -Severity Information 
}
$cipherlist = @()

if ([Environment]::OSVersion.Version.Major -lt 10) 
{
    $cipherlist += Get-BaseCipherSuitesOlderWindows -isExcellenceOrder $configureExcellenceOrder
    $cipherlist += Get-BrowserCompatCipherSuitesOlderWindows -isExcellenceOrder $configureExcellenceOrder
}
else
{
    $cipherlist += Get-BaseCipherSuitesWin10Above -isExcellenceOrder $configureExcellenceOrder
}
$cipherorder = [System.String]::Join(",", $cipherlist)
 Write-Host "Appropriate ciphersuite order : $cipherorder"
 Write-Log -Message "Appropriate ciphersuite order : $cipherorder"  -Logfile $logLocation -Severity Information
  
$CipherSuiteRegKey = "HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002" 
   
if (!(Test-Path -Path $CipherSuiteRegKey)) 
{ 
    New-Item $CipherSuiteRegKey | Out-Null 
    $reboot = $True 
    Write-Log -Message "Creating key: $($CipherSuiteRegKey) "  -Logfile $logLocation -Severity Information
} 
 
$val = (Get-Item -Path $CipherSuiteRegKey -ErrorAction SilentlyContinue).GetValue("Functions", $null)
Write-Log -Message "Previous cipher suite value: $val  "  -Logfile $logLocation -Severity Information
Write-Log -Message "New cipher suite value     : $cipherorder  "  -Logfile $logLocation -Severity Information		 
	   
if ($val -ne $cipherorder) 
{ 
    Write-Log -Message "Cipher suite order needs to be updated. "  -Logfile $logLocation -Severity Information
    Write-Host "The original cipher suite order needs to be updated", `n, $val 
    Set-ItemProperty -Path $CipherSuiteRegKey -Name Functions -Value $cipherorder 
    Write-Log -Message "Cipher suite value was updated. "  -Logfile $logLocation -Severity Information
    $reboot = $True 
}
else
{
    Write-Log -Message "Cipher suite order does not need to be updated. "  -Logfile $logLocation -Severity Information
	Write-Log -Message "Cipher suite value was not updated as there was no change. " -Logfile $logLocation -Severity Information
}
	   	
#****************************** CHECK THE FIPS SETTING WHICH IMPACTS RDP'S ALLOWED CIPHERS **************************
#Check for FipsSettings
Write-Log -Message "Checking to see if reg keys exist and if MinEncryptionLevel is set to 4"  -Logfile $logLocation -Severity Information
$result = Test-RegistryValueForFipsSettings 
$reboot = $reboot -or $result
	
 
#************************************** REBOOT **************************************

if ($RebootIfRequired)  
{
    Write-Log -Message "You set the RebootIfRequired flag to true. If changes are made, the system will reboot "  -Logfile $logLocation -Severity Information
    # If any settings were changed, reboot 
    If ($reboot) 
    { 
        Write-Log -Message "Rebooting now... "  -Logfile $logLocation -Severity Information
        Write-Log -Message "Using this command: shutdown.exe /r /t 5 /c ""Crypto settings changed"" /f /d p:2:4 "  -Logfile $logLocation -Severity Information
        Write-Host "Rebooting now..." 
        shutdown.exe /r /t 5 /c "Crypto settings changed" /f /d p:2:4 
    }
    Else 
    { 
        Write-Host "Nothing get updated."
        Write-Log -Message "Nothing get updated. "  -Logfile $logLocation -Severity Information
    }  
}
else
{

    Write-Log -Message "You set the RebootIfRequired flag to false. If changes are made, the system will NOT reboot "  -Logfile $logLocation -Severity Information
    Write-Log -Message "No changes will take effect until a reboot has been completed. "  -Logfile $logLocation -Severity Information
    Write-Log -Message "Script does not include a reboot by design" -Logfile $logLocation -Severity Information
}
Write-Log -Message "========== End of logging for a script execution =========="  -Logfile $logLocation -Severity Information
# SIG # Begin signature block
# MIIjhgYJKoZIhvcNAQcCoIIjdzCCI3MCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAHtlEJwNffjnOP
# Sr2t1yq5EfE0ll4GozyZt3UXO9BXKKCCDYEwggX/MIID56ADAgECAhMzAAABh3IX
# chVZQMcJAAAAAAGHMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjAwMzA0MTgzOTQ3WhcNMjEwMzAzMTgzOTQ3WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDOt8kLc7P3T7MKIhouYHewMFmnq8Ayu7FOhZCQabVwBp2VS4WyB2Qe4TQBT8aB
# znANDEPjHKNdPT8Xz5cNali6XHefS8i/WXtF0vSsP8NEv6mBHuA2p1fw2wB/F0dH
# sJ3GfZ5c0sPJjklsiYqPw59xJ54kM91IOgiO2OUzjNAljPibjCWfH7UzQ1TPHc4d
# weils8GEIrbBRb7IWwiObL12jWT4Yh71NQgvJ9Fn6+UhD9x2uk3dLj84vwt1NuFQ
# itKJxIV0fVsRNR3abQVOLqpDugbr0SzNL6o8xzOHL5OXiGGwg6ekiXA1/2XXY7yV
# Fc39tledDtZjSjNbex1zzwSXAgMBAAGjggF+MIIBejAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQUhov4ZyO96axkJdMjpzu2zVXOJcsw
# UAYDVR0RBEkwR6RFMEMxKTAnBgNVBAsTIE1pY3Jvc29mdCBPcGVyYXRpb25zIFB1
# ZXJ0byBSaWNvMRYwFAYDVQQFEw0yMzAwMTIrNDU4Mzg1MB8GA1UdIwQYMBaAFEhu
# ZOVQBdOCqhc3NyK1bajKdQKVMFQGA1UdHwRNMEswSaBHoEWGQ2h0dHA6Ly93d3cu
# bWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY0NvZFNpZ1BDQTIwMTFfMjAxMS0w
# Ny0wOC5jcmwwYQYIKwYBBQUHAQEEVTBTMFEGCCsGAQUFBzAChkVodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY0NvZFNpZ1BDQTIwMTFfMjAx
# MS0wNy0wOC5jcnQwDAYDVR0TAQH/BAIwADANBgkqhkiG9w0BAQsFAAOCAgEAixmy
# S6E6vprWD9KFNIB9G5zyMuIjZAOuUJ1EK/Vlg6Fb3ZHXjjUwATKIcXbFuFC6Wr4K
# NrU4DY/sBVqmab5AC/je3bpUpjtxpEyqUqtPc30wEg/rO9vmKmqKoLPT37svc2NV
# BmGNl+85qO4fV/w7Cx7J0Bbqk19KcRNdjt6eKoTnTPHBHlVHQIHZpMxacbFOAkJr
# qAVkYZdz7ikNXTxV+GRb36tC4ByMNxE2DF7vFdvaiZP0CVZ5ByJ2gAhXMdK9+usx
# zVk913qKde1OAuWdv+rndqkAIm8fUlRnr4saSCg7cIbUwCCf116wUJ7EuJDg0vHe
# yhnCeHnBbyH3RZkHEi2ofmfgnFISJZDdMAeVZGVOh20Jp50XBzqokpPzeZ6zc1/g
# yILNyiVgE+RPkjnUQshd1f1PMgn3tns2Cz7bJiVUaqEO3n9qRFgy5JuLae6UweGf
# AeOo3dgLZxikKzYs3hDMaEtJq8IP71cX7QXe6lnMmXU/Hdfz2p897Zd+kU+vZvKI
# 3cwLfuVQgK2RZ2z+Kc3K3dRPz2rXycK5XCuRZmvGab/WbrZiC7wJQapgBodltMI5
# GMdFrBg9IeF7/rP4EqVQXeKtevTlZXjpuNhhjuR+2DMt/dWufjXpiW91bo3aH6Ea
# jOALXmoxgltCp1K7hrS6gmsvj94cLRf50QQ4U8Qwggd6MIIFYqADAgECAgphDpDS
# AAAAAAADMA0GCSqGSIb3DQEBCwUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0
# ZSBBdXRob3JpdHkgMjAxMTAeFw0xMTA3MDgyMDU5MDlaFw0yNjA3MDgyMTA5MDla
# MH4xCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdS
# ZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMT
# H01pY3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTEwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQCr8PpyEBwurdhuqoIQTTS68rZYIZ9CGypr6VpQqrgG
# OBoESbp/wwwe3TdrxhLYC/A4wpkGsMg51QEUMULTiQ15ZId+lGAkbK+eSZzpaF7S
# 35tTsgosw6/ZqSuuegmv15ZZymAaBelmdugyUiYSL+erCFDPs0S3XdjELgN1q2jz
# y23zOlyhFvRGuuA4ZKxuZDV4pqBjDy3TQJP4494HDdVceaVJKecNvqATd76UPe/7
# 4ytaEB9NViiienLgEjq3SV7Y7e1DkYPZe7J7hhvZPrGMXeiJT4Qa8qEvWeSQOy2u
# M1jFtz7+MtOzAz2xsq+SOH7SnYAs9U5WkSE1JcM5bmR/U7qcD60ZI4TL9LoDho33
# X/DQUr+MlIe8wCF0JV8YKLbMJyg4JZg5SjbPfLGSrhwjp6lm7GEfauEoSZ1fiOIl
# XdMhSz5SxLVXPyQD8NF6Wy/VI+NwXQ9RRnez+ADhvKwCgl/bwBWzvRvUVUvnOaEP
# 6SNJvBi4RHxF5MHDcnrgcuck379GmcXvwhxX24ON7E1JMKerjt/sW5+v/N2wZuLB
# l4F77dbtS+dJKacTKKanfWeA5opieF+yL4TXV5xcv3coKPHtbcMojyyPQDdPweGF
# RInECUzF1KVDL3SV9274eCBYLBNdYJWaPk8zhNqwiBfenk70lrC8RqBsmNLg1oiM
# CwIDAQABo4IB7TCCAekwEAYJKwYBBAGCNxUBBAMCAQAwHQYDVR0OBBYEFEhuZOVQ
# BdOCqhc3NyK1bajKdQKVMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsGA1Ud
# DwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFHItOgIxkEO5FAVO
# 4eqnxzHRI4k0MFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwubWljcm9zb2Z0
# LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8wM18y
# Mi5jcmwwXgYIKwYBBQUHAQEEUjBQME4GCCsGAQUFBzAChkJodHRwOi8vd3d3Lm1p
# Y3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8wM18y
# Mi5jcnQwgZ8GA1UdIASBlzCBlDCBkQYJKwYBBAGCNy4DMIGDMD8GCCsGAQUFBwIB
# FjNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2RvY3MvcHJpbWFyeWNw
# cy5odG0wQAYIKwYBBQUHAgIwNB4yIB0ATABlAGcAYQBsAF8AcABvAGwAaQBjAHkA
# XwBzAHQAYQB0AGUAbQBlAG4AdAAuIB0wDQYJKoZIhvcNAQELBQADggIBAGfyhqWY
# 4FR5Gi7T2HRnIpsLlhHhY5KZQpZ90nkMkMFlXy4sPvjDctFtg/6+P+gKyju/R6mj
# 82nbY78iNaWXXWWEkH2LRlBV2AySfNIaSxzzPEKLUtCw/WvjPgcuKZvmPRul1LUd
# d5Q54ulkyUQ9eHoj8xN9ppB0g430yyYCRirCihC7pKkFDJvtaPpoLpWgKj8qa1hJ
# Yx8JaW5amJbkg/TAj/NGK978O9C9Ne9uJa7lryft0N3zDq+ZKJeYTQ49C/IIidYf
# wzIY4vDFLc5bnrRJOQrGCsLGra7lstnbFYhRRVg4MnEnGn+x9Cf43iw6IGmYslmJ
# aG5vp7d0w0AFBqYBKig+gj8TTWYLwLNN9eGPfxxvFX1Fp3blQCplo8NdUmKGwx1j
# NpeG39rz+PIWoZon4c2ll9DuXWNB41sHnIc+BncG0QaxdR8UvmFhtfDcxhsEvt9B
# xw4o7t5lL+yX9qFcltgA1qFGvVnzl6UJS0gQmYAf0AApxbGbpT9Fdx41xtKiop96
# eiL6SJUfq/tHI4D1nvi/a7dLl+LrdXga7Oo3mXkYS//WsyNodeav+vyL6wuA6mk7
# r/ww7QRMjt/fdW1jkT3RnVZOT7+AVyKheBEyIXrvQQqxP/uozKRdwaGIm1dxVk5I
# RcBCyZt2WwqASGv9eZ/BvW1taslScxMNelDNMYIVWzCCFVcCAQEwgZUwfjELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEoMCYGA1UEAxMfTWljcm9z
# b2Z0IENvZGUgU2lnbmluZyBQQ0EgMjAxMQITMwAAAYdyF3IVWUDHCQAAAAABhzAN
# BglghkgBZQMEAgEFAKCBrjAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgor
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQgOQvu7NUq
# wmve+qCoalj/s9HX5Hz9/zYISdJyOFTC4FIwQgYKKwYBBAGCNwIBDDE0MDKgFIAS
# AE0AaQBjAHIAbwBzAG8AZgB0oRqAGGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbTAN
# BgkqhkiG9w0BAQEFAASCAQAHbtGz0AChe0qMPM3c7iU8BQCfJklePUlAlhwFSuCx
# careoloxao+ZtS+dQRlrxLu/ZSqtmJHNsyRoWzsHdOs65pwUYhV3svzaXd7pJwkc
# nbDXedLBbNuQrQrrL2xbGtzT3U+EwgpJ1TTEYwHgqkTFogIelGa2sjD5N+4Vvalq
# t+vxaYrWwkTtsm0qczLKGRUjJqCjARjviE1xsOvs4zwbpXx/bEs/6M7U9tR+w/DS
# nDY/5KAKYET0DCVDhmsMmzJi3xXdBr4sAz0484AAB0CIRVgPCgdgr8E0NQUESJzm
# xm3K4bMAgTMWRiGTL4MRYSuMIn09sbfYXP9hjXLvTV4YoYIS5TCCEuEGCisGAQQB
# gjcDAwExghLRMIISzQYJKoZIhvcNAQcCoIISvjCCEroCAQMxDzANBglghkgBZQME
# AgEFADCCAVEGCyqGSIb3DQEJEAEEoIIBQASCATwwggE4AgEBBgorBgEEAYRZCgMB
# MDEwDQYJYIZIAWUDBAIBBQAEIJBynrmlQmGS0UNGTk53HVKEc4aHvNdYrs5eCcHM
# puc5AgZfEgElnvMYEzIwMjAwNzI0MTgwNDM3Ljg3NlowBIACAfSggdCkgc0wgcox
# CzAJBgNVBAYTAlVTMQswCQYDVQQIEwJXQTEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQLEyRNaWNyb3NvZnQg
# SXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJjAkBgNVBAsTHVRoYWxlcyBUU1Mg
# RVNOOkUwNDEtNEJFRS1GQTdFMSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFt
# cCBzZXJ2aWNloIIOPDCCBPEwggPZoAMCAQICEzMAAAEHfjdomIdaN9YAAAAAAQcw
# DQYJKoZIhvcNAQELBQAwfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0
# b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3Jh
# dGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwHhcN
# MTkxMDA4MTczODM1WhcNMjEwMTAzMTczODM1WjCByjELMAkGA1UEBhMCVVMxCzAJ
# BgNVBAgTAldBMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQg
# Q29ycG9yYXRpb24xLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5kIE9wZXJhdGlv
# bnMgTGltaXRlZDEmMCQGA1UECxMdVGhhbGVzIFRTUyBFU046RTA0MS00QkVFLUZB
# N0UxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIHNlcnZpY2UwggEiMA0G
# CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDUuqOUlbaeWirgwbCwhhNIOqTshpo+
# QdSYxAt9JnkeulQFeKrQ6rOSECXxwgOjL/TNMIXtkig1MaifFON6si/Ri+AsV8Gu
# rQp4fylJzLDMFdJcGSpV3CGRdpDb0au8kNQLmnZuxLxAL91R7//3mH2QDQI20w3G
# 06s+Xv8+js9wQksXAfclXX1TJoBIx1Pi1FGqCnY3KlW81+Plhz0T4yStm1MgnqH4
# RKYyPdcempCYC/BI04Ph2EJL+uQQfAfYdbf9vGqpKYjsuktnWr5uowD3H5At+x3l
# YH5rz4JCleKjeLpB/j74H7VZ0I5eTEbls9e2lEKaUzb9o0wjnjDc+t4BAgMBAAGj
# ggEbMIIBFzAdBgNVHQ4EFgQUNOHjlxlIJXMcP9n/0ogYdX8p6HcwHwYDVR0jBBgw
# FoAU1WM6XIoxkPNDe3xGG8UzaFqFbVUwVgYDVR0fBE8wTTBLoEmgR4ZFaHR0cDov
# L2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwvcHJvZHVjdHMvTWljVGltU3RhUENB
# XzIwMTAtMDctMDEuY3JsMFoGCCsGAQUFBwEBBE4wTDBKBggrBgEFBQcwAoY+aHR0
# cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNUaW1TdGFQQ0FfMjAx
# MC0wNy0wMS5jcnQwDAYDVR0TAQH/BAIwADATBgNVHSUEDDAKBggrBgEFBQcDCDAN
# BgkqhkiG9w0BAQsFAAOCAQEAGN3/7XWSzHGKjk444w+2q1D3k7Bh/ZahUvWHFJ6E
# UKU5vLzEGsdsgJSvWXHZDRrpf5rcUGQyjnlo1hAY1mDteNKFushS6bedxcxPHJje
# lVZ9N2/e5+/7zLu18YjnKw5bFu7dWqYBMI3J0FOr56XJOJ1KTtMiJhpxuib+FWy+
# pyhVVgHGTUHuUdbE09dY9WxuRsbpb4DdWAWNrPDB6VAOO50QfEj+0tW+zF6h3RhB
# TI0ilj0+AzgXE+6DyJ7/br6aVvCEvNRJzE6akJnMyn/kzmC32LxvRZWKEwWDR0Fn
# zeXj5ynSStZ6iifTBP7gqiDsidguxh+BFX7HxhN1eHf7jTCCBnEwggRZoAMCAQIC
# CmEJgSoAAAAAAAIwDQYJKoZIhvcNAQELBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBSb290IENlcnRp
# ZmljYXRlIEF1dGhvcml0eSAyMDEwMB4XDTEwMDcwMTIxMzY1NVoXDTI1MDcwMTIx
# NDY1NVowfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNV
# BAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQG
# A1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwggEiMA0GCSqGSIb3
# DQEBAQUAA4IBDwAwggEKAoIBAQCpHQ28dxGKOiDs/BOX9fp/aZRrdFQQ1aUKAIKF
# ++18aEssX8XD5WHCdrc+Zitb8BVTJwQxH0EbGpUdzgkTjnxhMFmxMEQP8WCIhFRD
# DNdNuDgIs0Ldk6zWczBXJoKjRQ3Q6vVHgc2/JGAyWGBG8lhHhjKEHnRhZ5FfgVSx
# z5NMksHEpl3RYRNuKMYa+YaAu99h/EbBJx0kZxJyGiGKr0tkiVBisV39dx898Fd1
# rL2KQk1AUdEPnAY+Z3/1ZsADlkR+79BL/W7lmsqxqPJ6Kgox8NpOBpG2iAg16Hgc
# sOmZzTznL0S6p/TcZL2kAcEgCZN4zfy8wMlEXV4WnAEFTyJNAgMBAAGjggHmMIIB
# 4jAQBgkrBgEEAYI3FQEEAwIBADAdBgNVHQ4EFgQU1WM6XIoxkPNDe3xGG8UzaFqF
# bVUwGQYJKwYBBAGCNxQCBAweCgBTAHUAYgBDAEEwCwYDVR0PBAQDAgGGMA8GA1Ud
# EwEB/wQFMAMBAf8wHwYDVR0jBBgwFoAU1fZWy4/oolxiaNE9lJBb186aGMQwVgYD
# VR0fBE8wTTBLoEmgR4ZFaHR0cDovL2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwv
# cHJvZHVjdHMvTWljUm9vQ2VyQXV0XzIwMTAtMDYtMjMuY3JsMFoGCCsGAQUFBwEB
# BE4wTDBKBggrBgEFBQcwAoY+aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9j
# ZXJ0cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5jcnQwgaAGA1UdIAEB/wSBlTCB
# kjCBjwYJKwYBBAGCNy4DMIGBMD0GCCsGAQUFBwIBFjFodHRwOi8vd3d3Lm1pY3Jv
# c29mdC5jb20vUEtJL2RvY3MvQ1BTL2RlZmF1bHQuaHRtMEAGCCsGAQUFBwICMDQe
# MiAdAEwAZQBnAGEAbABfAFAAbwBsAGkAYwB5AF8AUwB0AGEAdABlAG0AZQBuAHQA
# LiAdMA0GCSqGSIb3DQEBCwUAA4ICAQAH5ohRDeLG4Jg/gXEDPZ2joSFvs+umzPUx
# vs8F4qn++ldtGTCzwsVmyWrf9efweL3HqJ4l4/m87WtUVwgrUYJEEvu5U4zM9GAS
# inbMQEBBm9xcF/9c+V4XNZgkVkt070IQyK+/f8Z/8jd9Wj8c8pl5SpFSAK84Dxf1
# L3mBZdmptWvkx872ynoAb0swRCQiPM/tA6WWj1kpvLb9BOFwnzJKJ/1Vry/+tuWO
# M7tiX5rbV0Dp8c6ZZpCM/2pif93FSguRJuI57BlKcWOdeyFtw5yjojz6f32WapB4
# pm3S4Zz5Hfw42JT0xqUKloakvZ4argRCg7i1gJsiOCC1JeVk7Pf0v35jWSUPei45
# V3aicaoGig+JFrphpxHLmtgOR5qAxdDNp9DvfYPw4TtxCd9ddJgiCGHasFAeb73x
# 4QDf5zEHpJM692VHeOj4qEir995yfmFrb3epgcunCaw5u+zGy9iCtHLNHfS4hQEe
# gPsbiSpUObJb2sgNVZl6h3M7COaYLeqN4DMuEin1wC9UJyH3yKxO2ii4sanblrKn
# QqLJzxlBTeCG+SqaoxFmMNO7dDJL32N79ZmKLxvHIa9Zta7cRDyXUHHXodLFVeNp
# 3lfB0d4wwP3M5k37Db9dT+mdHhk4L7zPWAUu7w2gUDXa7wknHNWzfjUeCLraNtvT
# X4/edIhJEqGCAs4wggI3AgEBMIH4oYHQpIHNMIHKMQswCQYDVQQGEwJVUzELMAkG
# A1UECBMCV0ExEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
# b3Jwb3JhdGlvbjEtMCsGA1UECxMkTWljcm9zb2Z0IElyZWxhbmQgT3BlcmF0aW9u
# cyBMaW1pdGVkMSYwJAYDVQQLEx1UaGFsZXMgVFNTIEVTTjpFMDQxLTRCRUUtRkE3
# RTElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgc2VydmljZaIjCgEBMAcG
# BSsOAwIaAxUAwwu+tfgG3rC7RZrxuFO2CmZSfPiggYMwgYCkfjB8MQswCQYDVQQG
# EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQg
# VGltZS1TdGFtcCBQQ0EgMjAxMDANBgkqhkiG9w0BAQUFAAIFAOLFEVUwIhgPMjAy
# MDA3MjQxNTUwNDVaGA8yMDIwMDcyNTE1NTA0NVowdzA9BgorBgEEAYRZCgQBMS8w
# LTAKAgUA4sURVQIBADAKAgEAAgIa9QIB/zAHAgEAAgIR9DAKAgUA4sZi1QIBADA2
# BgorBgEEAYRZCgQCMSgwJjAMBgorBgEEAYRZCgMCoAowCAIBAAIDB6EgoQowCAIB
# AAIDAYagMA0GCSqGSIb3DQEBBQUAA4GBADwvhE9bln801RR+oEXjtPJXTqtYMakR
# ymItUlO2HRorDqEv2SJR/V/kQjcsqS6ig54bOiKs0Il2fW/s/pi+x1ydJMpOyhM7
# zzqm3acQ9kbYHIDoPWVT/Rq2Oo33Dq380zXENcc0hpLAKF3Cu06SbbNbqu+A/wbI
# z5IClz6kU8kiMYIDDTCCAwkCAQEwgZMwfDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
# dCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENB
# IDIwMTACEzMAAAEHfjdomIdaN9YAAAAAAQcwDQYJYIZIAWUDBAIBBQCgggFKMBoG
# CSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAvBgkqhkiG9w0BCQQxIgQg6+NCew+c
# OhYIOzhUKofOF7MxtgOvSMWQCMCIWlTFNMgwgfoGCyqGSIb3DQEJEAIvMYHqMIHn
# MIHkMIG9BCBBYvCj4pFkwhumagATn0gLh9fdDNzImQkKNeOtRj/LHjCBmDCBgKR+
# MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdS
# ZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMT
# HU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAABB343aJiHWjfWAAAA
# AAEHMCIEIGIH6vLdbEFNnxTxBhtIN7CtmhcKy/9m6/xoAA3LHzXUMA0GCSqGSIb3
# DQEBCwUABIIBAKGg3zNulscnGBDlD6Q/U6yLQ5dN3gF9UrprgACiQ1gs/DexU7oC
# hjNZxBnH5RTA/7q9TFf2a1rBydHWVnqXuuQQJ0HuskdpXahxR4y1jboDdGwr7F08
# v/gmPeeUik28Je72QZp5m/R0O61/kMQaDpLO9iPH0Z9iMGfqJonFPDeY4VX8Da2n
# cPY7mrv6YAI+ydZ+mUdBp2yjas7+/N8MntcNtAO0HpWFXQTAmb77RrSssfeZphRA
# mBD+gLx5C3q4uSmuOqaQxUaF0y8FeuetHp0bw2sfce6GlMXJwzTpC6HvXnaVtMy0
# pgzd/KPHW7EgSvmRVKmvwiQGiZBoRG/Gcg8=
# SIG # End signature block
