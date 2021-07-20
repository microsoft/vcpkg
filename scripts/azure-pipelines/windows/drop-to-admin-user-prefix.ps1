param(
  [string]$AdminUserPassword = $null
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
if (-Not [string]::IsNullOrEmpty($AdminUserPassword)) {
  $PsExecPath = 'C:\PsExec64.exe'
  $PsExecArgs = @(
    '-u',
    'AdminUser',
    '-p',
    $AdminUserPassword,
    '-accepteula',
    '-i',
    '-h',
    'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe',
    '-ExecutionPolicy',
    'Unrestricted',
    '-File',
    $PSCommandPath
  )

  Write-Host "Executing: $PsExecPath $PsExecArgs"
  $proc = Start-Process -FilePath $PsExecPath -ArgumentList $PsExecArgs -Wait -PassThru
  exit $proc.ExitCode
}
