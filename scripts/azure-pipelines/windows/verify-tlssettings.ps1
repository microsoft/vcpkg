# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

$protocolsPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols'
$failures = @()

foreach ($protocol in 'TLS 1.0', 'TLS 1.1') {
  foreach ($role in 'Client', 'Server') {
    $path = Join-Path $protocolsPath "$protocol\$role"
    $settings = Get-ItemProperty -LiteralPath $path -ErrorAction SilentlyContinue
    if ($null -eq $settings) {
      $failures += "$protocol $role has no explicit disabled configuration."
      continue
    }

    if ($settings.Enabled -ne 0) {
      $failures += "$protocol $role Enabled must be 0, but was $($settings.Enabled)."
    }

    if ($settings.DisabledByDefault -ne 1) {
      $failures += "$protocol $role DisabledByDefault must be 1, but was $($settings.DisabledByDefault)."
    }
  }
}

if ($failures.Count -ne 0) {
  throw "Legacy TLS protocols are not disabled:`n$($failures -join "`n")"
}

Write-Host 'TLS 1.0 and TLS 1.1 are disabled for Schannel clients and servers.'
