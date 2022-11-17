# This script runs all the scripts we run on Azure machines to deploy prerequisites,
# and assumes it is being run as an admin user.

. "$PSScriptRoot\utility-prefix.ps1"

. "$PSScriptRoot\deploy-tlssettings.ps1" -RebootIfRequired 0
. "$PSScriptRoot\deploy-windows-sdks.ps1"
. "$PSScriptRoot\deploy-visual-studio.ps1"
. "$PSScriptRoot\deploy-mpi.ps1"
. "$PSScriptRoot\deploy-cuda.ps1"
. "$PSScriptRoot\deploy-inteloneapi.ps1"
. "$PSScriptRoot\deploy-pwsh.ps1"
try {
    Copy-Item "$PSScriptRoot\deploy-settings.txt" "$PSScriptRoot\deploy-settings.ps1"
    . "$PSScriptRoot\deploy-settings.ps1"
} finally {
    Remove-Item "$PSScriptRoot\deploy-settings.ps1"
}
