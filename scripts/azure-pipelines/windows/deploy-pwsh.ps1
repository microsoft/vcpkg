# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

# REPLACE WITH DROP-TO-ADMIN-USER-PREFIX.ps1

# REPLACE WITH UTILITY-PREFIX.ps1

$PwshUrl = 'https://github.com/PowerShell/PowerShell/releases/download/v7.3.8/PowerShell-7.3.8-win-x64.msi'
InstallMSI -Url $PwshUrl -Name 'PowerShell Core'
