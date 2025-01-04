# Define the list of whitelisted environment variables
$whitelist = @(
    "PATH", `
#    "USERPROFILE", `
    "ALLUSERSPROFILE", `
    "CommandPromptType", `
    "CommonProgramFiles", `
    "CommonProgramFiles(x86)", `
    "CommonProgramW6432", `
#    "COMPUTERNAME", `
    "ComSpec", `
#    "HOMEDRIVE", `
#    "HOMEPATH", `
    "ALLUSERSPROFILE", `
#    "LOCALAPPDATA", `
#    "LOGONSERVER", `
    "OS", `
    "PATHEXT", `
    "PROCESSOR_ARCHITECTURE", `
    "PROCESSOR_IDENTIFIER", `
    "PROCESSOR_LEVEL", `
    "PROCESSOR_REVISION", `
    "ProgramData", `
    "ProgramFiles", `
    "ProgramFiles(x86)", `
    "ProgramW6432", `
    "PROMPT", `
    "PSModulePath", `
    "PUBLIC", `
    "SystemDrive", `
    "SystemRoot", `
    "TEMP", `
    "TMP", `
#    "USERDOMAIN", `
#    "USERDOMAIN_ROAMINGPROFILE", `
#    "USERNAME", `
#    "USERPROFILE", `
    "windir", `
    "GIT_ASKPASS", `
    "VSCMD_SKIP_SENDTELEMETRY", `
    "VCPKG_COMMAND", `
    "VCPKG_TOOLCHAIN_ENV_ALREADY_SET", `
    "HTTP_PROXY", `
    "HTTPS_PROXY"
    ) # Add more as needed

# Clear all environment variables
$envVars = [System.Environment]::GetEnvironmentVariables()
foreach ($envVar in $envVars.Keys) {
    if ($whitelist -notcontains $envVar) {
        Remove-Item "Env:\$envVar" -ErrorAction SilentlyContinue
    }
}

#Get-ChildItem Env: | ForEach-Object { "$($_.Name) = $($_.Value)" }