[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
param(
  [string] $ProjectRoot = (Get-Location).Path,

  [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9._-]*$')]
  [string] $Triplet = 'x64-windows-static',

  [switch] $Remove
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$propsBeginMarker = '<!-- crtsys-vcpkg-init:props:begin -->'
$propsEndMarker = '<!-- crtsys-vcpkg-init:props:end -->'
$targetsBeginMarker = '<!-- crtsys-vcpkg-init:targets:begin -->'
$targetsEndMarker = '<!-- crtsys-vcpkg-init:targets:end -->'
$generatedFileMarker = '<!-- crtsys-vcpkg-init:generated-file -->'

function Find-VcpkgManifestRoot {
  param([Parameter(Mandatory = $true)][string] $StartPath)

  $fullPath = [System.IO.Path]::GetFullPath($StartPath)
  if (-not (Test-Path -LiteralPath $fullPath -PathType Container)) {
    throw "Project directory was not found: $fullPath"
  }

  $directory = [System.IO.DirectoryInfo]::new($fullPath)
  while ($null -ne $directory) {
    if (Test-Path -LiteralPath (Join-Path $directory.FullName 'vcpkg.json')) {
      return $directory.FullName
    }
    $directory = $directory.Parent
  }

  throw "vcpkg.json was not found at or above '$fullPath'."
}

function Assert-MsBuildProject {
  param(
    [Parameter(Mandatory = $true)][string] $Path,
    [Parameter(Mandatory = $true)][string] $Content
  )

  $settings = [System.Xml.XmlReaderSettings]::new()
  $settings.DtdProcessing = [System.Xml.DtdProcessing]::Prohibit
  $reader = [System.Xml.XmlReader]::Create(
    [System.IO.StringReader]::new($Content),
    $settings
  )
  try {
    $document = [System.Xml.XmlDocument]::new()
    $document.Load($reader)
  } catch {
    throw "Refusing to modify invalid MSBuild XML '$Path': $($_.Exception.Message)"
  } finally {
    $reader.Dispose()
  }

  if ($document.DocumentElement.LocalName -ne 'Project') {
    throw "Expected the root element in '$Path' to be Project."
  }
}

function Convert-Newlines {
  param(
    [Parameter(Mandatory = $true)][string] $Content,
    [Parameter(Mandatory = $true)][string] $Newline
  )

  return ($Content -replace "`r`n|`r|`n", $Newline)
}

function Write-Utf8Text {
  param(
    [Parameter(Mandatory = $true)][string] $Path,
    [Parameter(Mandatory = $true)][string] $Content
  )

  $utf8WithoutBom = [System.Text.UTF8Encoding]::new($false)
  [System.IO.File]::WriteAllText($Path, $Content, $utf8WithoutBom)
}

function Get-MarkerPattern {
  param(
    [Parameter(Mandatory = $true)][string] $BeginMarker,
    [Parameter(Mandatory = $true)][string] $EndMarker
  )

  return '(?ms)[ \t]*' + [regex]::Escape($BeginMarker) +
    '.*?' + [regex]::Escape($EndMarker) + '[ \t]*(?:\r?\n)?'
}

function Set-MsBuildIntegrationBlock {
  param(
    [Parameter(Mandatory = $true)][string] $Path,
    [Parameter(Mandatory = $true)][string] $BeginMarker,
    [Parameter(Mandatory = $true)][string] $EndMarker,
    [Parameter(Mandatory = $true)][string] $Block
  )

  $exists = Test-Path -LiteralPath $Path
  $newline = "`r`n"
  if ($exists) {
    $content = Get-Content -LiteralPath $Path -Raw
    Assert-MsBuildProject -Path $Path -Content $content
    if ($content.Contains("`r`n")) {
      $newline = "`r`n"
    } else {
      $newline = "`n"
    }
  } else {
    $content = "<Project>$newline  $generatedFileMarker$newline</Project>$newline"
  }

  $hasBegin = $content.Contains($BeginMarker)
  $hasEnd = $content.Contains($EndMarker)
  if ($hasBegin -ne $hasEnd) {
    throw "Refusing to modify '$Path' because its crtsys markers are incomplete."
  }

  $normalizedBlock = Convert-Newlines -Content $Block -Newline $newline
  if ($hasBegin) {
    $pattern = Get-MarkerPattern -BeginMarker $BeginMarker -EndMarker $EndMarker
    $updated = [regex]::Replace($content, $pattern, $normalizedBlock + $newline, 1)
  } else {
    $closingProject = [regex]::Match($content, '(?is)</Project\s*>\s*$')
    if ($closingProject.Success) {
      $prefix = $content.Substring(0, $closingProject.Index).TrimEnd()
      $suffix = $content.Substring($closingProject.Index)
      $updated = $prefix + $newline + $normalizedBlock + $newline + $suffix
    } else {
      $selfClosingProject = [regex]::Match(
        $content,
        '(?is)<Project(?<attributes>[^>]*)/\s*>\s*$'
      )
      if (-not $selfClosingProject.Success) {
        throw "Unable to locate the closing Project element in '$Path'."
      }
      $replacement = '<Project' + $selfClosingProject.Groups['attributes'].Value +
        '>' + $newline + $normalizedBlock + $newline + '</Project>' + $newline
      $updated = $content.Substring(0, $selfClosingProject.Index) + $replacement
    }
  }

  Assert-MsBuildProject -Path $Path -Content $updated
  if ($updated -ceq $content) {
    return $false
  }

  if ($PSCmdlet.ShouldProcess($Path, 'Configure crtsys vcpkg integration')) {
    Write-Utf8Text -Path $Path -Content $updated
  }
  return $true
}

function Remove-MsBuildIntegrationBlock {
  param(
    [Parameter(Mandatory = $true)][string] $Path,
    [Parameter(Mandatory = $true)][string] $BeginMarker,
    [Parameter(Mandatory = $true)][string] $EndMarker
  )

  if (-not (Test-Path -LiteralPath $Path)) {
    return $false
  }

  $content = Get-Content -LiteralPath $Path -Raw
  Assert-MsBuildProject -Path $Path -Content $content
  $hasBegin = $content.Contains($BeginMarker)
  $hasEnd = $content.Contains($EndMarker)
  if ($hasBegin -ne $hasEnd) {
    throw "Refusing to modify '$Path' because its crtsys markers are incomplete."
  }
  if (-not $hasBegin) {
    return $false
  }

  $pattern = Get-MarkerPattern -BeginMarker $BeginMarker -EndMarker $EndMarker
  $updated = [regex]::Replace($content, $pattern, '', 1)
  $wasGenerated = $updated.Contains($generatedFileMarker)
  $updated = $updated.Replace($generatedFileMarker, '')

  if ($wasGenerated -and
      [regex]::IsMatch($updated, '(?is)^\s*<Project[^>]*>\s*</Project>\s*$')) {
    if ($PSCmdlet.ShouldProcess($Path, 'Remove generated MSBuild file')) {
      Remove-Item -LiteralPath $Path
    }
    return $true
  }

  Assert-MsBuildProject -Path $Path -Content $updated
  if ($PSCmdlet.ShouldProcess($Path, 'Remove crtsys vcpkg integration')) {
    Write-Utf8Text -Path $Path -Content $updated
  }
  return $true
}

$manifestRoot = Find-VcpkgManifestRoot -StartPath $ProjectRoot
$propsPath = Join-Path $manifestRoot 'Directory.Build.props'
$targetsPath = Join-Path $manifestRoot 'Directory.Build.targets'

if ($Remove) {
  $propsChanged = Remove-MsBuildIntegrationBlock `
    -Path $propsPath `
    -BeginMarker $propsBeginMarker `
    -EndMarker $propsEndMarker
  $targetsChanged = Remove-MsBuildIntegrationBlock `
    -Path $targetsPath `
    -BeginMarker $targetsBeginMarker `
    -EndMarker $targetsEndMarker

  if ($propsChanged -or $targetsChanged) {
    Write-Host "Removed crtsys Visual Studio integration from '$manifestRoot'."
  } else {
    Write-Host "crtsys Visual Studio integration was not present in '$manifestRoot'."
  }
  return
}

$propsBlock = @"
  $propsBeginMarker
  <PropertyGroup Label="crtsys vcpkg integration">
    <VcpkgEnableManifest>true</VcpkgEnableManifest>
    <VcpkgTriplet Condition="'`$(VcpkgTriplet)' == ''">$Triplet</VcpkgTriplet>
  </PropertyGroup>
  $propsEndMarker
"@

$targetsBlock = @"
  $targetsBeginMarker
  <PropertyGroup Label="crtsys vcpkg integration">
    <_CrtSysVcpkgManifestRoot Condition="'`$(VcpkgManifestRoot)' != ''">`$([MSBuild]::NormalizeDirectory('`$(VcpkgManifestRoot)'))</_CrtSysVcpkgManifestRoot>
    <_CrtSysVcpkgManifestRoot Condition="'`$(_CrtSysVcpkgManifestRoot)' == ''">`$([MSBuild]::NormalizeDirectory('`$(MSBuildThisFileDirectory)'))</_CrtSysVcpkgManifestRoot>
    <_CrtSysVcpkgPackageRoot Condition="'`$(VcpkgInstalledDir)' != ''">`$([MSBuild]::NormalizeDirectory('`$(VcpkgInstalledDir)', '`$(VcpkgTriplet)'))</_CrtSysVcpkgPackageRoot>
    <_CrtSysVcpkgPackageRoot Condition="'`$(_CrtSysVcpkgPackageRoot)' == ''">`$([MSBuild]::NormalizeDirectory('`$(_CrtSysVcpkgManifestRoot)', 'vcpkg_installed', '`$(VcpkgTriplet)'))</_CrtSysVcpkgPackageRoot>
    <_CrtSysVcpkgBridge>`$(_CrtSysVcpkgPackageRoot)share\crtsys\msbuild\crtsys-vcpkg.targets</_CrtSysVcpkgBridge>
  </PropertyGroup>
  <Import Project="`$(_CrtSysVcpkgBridge)"
          Condition="Exists('`$(_CrtSysVcpkgBridge)')" />
  $targetsEndMarker
"@

$propsChanged = Set-MsBuildIntegrationBlock `
  -Path $propsPath `
  -BeginMarker $propsBeginMarker `
  -EndMarker $propsEndMarker `
  -Block $propsBlock
$targetsChanged = Set-MsBuildIntegrationBlock `
  -Path $targetsPath `
  -BeginMarker $targetsBeginMarker `
  -EndMarker $targetsEndMarker `
  -Block $targetsBlock

if ($propsChanged -or $targetsChanged) {
  Write-Host "Configured crtsys Visual Studio integration in '$manifestRoot'."
} else {
  Write-Host "crtsys Visual Studio integration is already configured in '$manifestRoot'."
}
Write-Host "Triplet: $Triplet"
Write-Host 'Reload the Visual Studio solution so the crtsys property pages are reevaluated.'
