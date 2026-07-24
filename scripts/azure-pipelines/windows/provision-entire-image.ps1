# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

# This script runs all the scripts we run on Azure machines to deploy prerequisites,
# and assumes it is being run as an admin user.

. "$PSScriptRoot\deploy-sevenzip.ps1"
. "$PSScriptRoot\deploy-visual-studio.ps1"
. "$PSScriptRoot\deploy-git.ps1"
. "$PSScriptRoot\deploy-cmake.ps1"
. "$PSScriptRoot\deploy-ninja.ps1"
. "$PSScriptRoot\deploy-mpi.ps1"
. "$PSScriptRoot\deploy-cuda.ps1"
. "$PSScriptRoot\deploy-cudnn.ps1"
. "$PSScriptRoot\deploy-pwsh.ps1"
. "$PSScriptRoot\deploy-azure-cli.ps1"
. "$PSScriptRoot\deploy-azcopy.ps1"
try {
    Copy-Item -LiteralPath "$PSScriptRoot\deploy-settings.txt" -Destination "$PSScriptRoot\deploy-settings.ps1"
    . "$PSScriptRoot\deploy-settings.ps1"
} finally {
    Remove-Item -LiteralPath "$PSScriptRoot\deploy-settings.ps1"
}
