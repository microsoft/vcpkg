# Capture environment variables for the System and User. Also add some special/built-in variables.
# These will be used to synthesize a clean environment
$specialEnvironmentMap = @{ "SystemDrive"=$env:SystemDrive; "SystemRoot"=$env:SystemRoot; "UserProfile"=$env:UserProfile; "TMP"=$env:TMP } # These are built-in and not set in the registry
$machineEnvironmentMap = [Environment]::GetEnvironmentVariables('Machine') # HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment
$userEnvironmentMap = [Environment]::GetEnvironmentVariables('User') # HKEY_CURRENT_USER\Environment

# Identify the keySet of environment variable names
$nameSet = ($specialEnvironmentMap.Keys + $machineEnvironmentMap.Keys + $userEnvironmentMap.Keys) | Sort-Object | Select-Object -Unique

# Any environment variable in the $nameSet should be restored to its original value
foreach ($name in $nameSet)
{
    if ($specialEnvironmentMap.ContainsKey($name))
    {
        [Environment]::SetEnvironmentVariable($name, $specialEnvironmentMap[$name], 'Process')
        continue;
    }

    # PATH needs to be concatenated as it has values in both machine and user environment. Any other values should be set.
    if ($name -eq 'path')
    {
        $pathValuePartial = @()
        # Machine values before user values
        $pathValuePartial += $machineEnvironmentMap[$name] -split ';'
        $pathValuePartial += $userEnvironmentMap[$name] -split ';'
        $pathValue = $pathValuePartial -join ';'
        [Environment]::SetEnvironmentVariable($name, $pathValue, 'Process')
        continue;
    }

    if ($userEnvironmentMap.ContainsKey($name))
    {
        [Environment]::SetEnvironmentVariable($name, $userEnvironmentMap[$name], 'Process')
        continue;
    }

    if ($machineEnvironmentMap.ContainsKey($name))
    {
        [Environment]::SetEnvironmentVariable($name, $machineEnvironmentMap[$name], 'Process')
        continue;
    }

    throw "Unreachable: Unknown variable $name"
}

# Any environment variable NOT in the $nameSet should be removed
$processEnvironmentMap = [Environment]::GetEnvironmentVariables('Process')
$variablesForRemoval = $processEnvironmentMap.Keys | Where-Object {$nameSet -notcontains $_}
foreach ($name in $variablesForRemoval)
{
    [Environment]::SetEnvironmentVariable($name, $null, 'Process')
}
