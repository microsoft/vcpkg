function Setup-Intel-MSVC-Env {
  param(
      [Parameter(Mandatory = $false)]
      [string]$OneApiRootDir = (Join-Path -Path $PSScriptRoot -ChildPath "../compiler/intel")
  )

  if (-not $env:INTEL_TOOLCHAIN_ENV_ALREADY_SET) {
      # Get the compiler root directory
      $CompilerRoot = Get-ChildItem -Directory -Path (Join-Path -Path $OneApiRootDir -ChildPath "compiler/*") | Select-Object -ExpandProperty FullName

      # Update INCLUDE environment variable
      $IncludeEnv = ($env:INCLUDE -split ';') + (Join-Path -Path $CompilerRoot -ChildPath "include")
      $env:INCLUDE = ($IncludeEnv -join ';')

      # Update LIB environment variable
      $LibEnv = ($env:LIB -split ';') + @(
          (Join-Path -Path $CompilerRoot -ChildPath "lib/clang/19/lib/windows"),
          (Join-Path -Path $CompilerRoot -ChildPath "opt/compiler/lib"),
          (Join-Path -Path $CompilerRoot -ChildPath "lib")
      )
      $env:LIB = ($LibEnv -join ';')

      # Update PATH environment variable
      $PathEnv = ($env:PATH -split ';') + (Join-Path -Path $CompilerRoot -ChildPath "bin")
      $env:PATH = ($PathEnv -join ';')

      # Set the INTEL_TOOLCHAIN_ENV_ALREADY_SET flag
      $env:INTEL_TOOLCHAIN_ENV_ALREADY_SET = "1"
  }
}

. .\msvc-env.ps1

Setup-Intel-MSVC-Env