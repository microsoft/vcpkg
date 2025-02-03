function Setup-LLVM-Env {
    param(
        [string]$LLVMInstallDir = (Join-Path -Path $PSScriptRoot -ChildPath "../compiler/llvm")
    )

    if (-not $env:LLVMInstallDir) {
        # Normalize the path
        $LLVMInstallDir = (Resolve-Path -Path $LLVMInstallDir).Path
        $env:LLVMInstallDir = $LLVMInstallDir
        $env:LLVMToolsVersion = "19"

        # Update PATH environment variable
        $env:PATH = "$LLVMInstallDir/bin;$env:PATH"
    }
}

. .\msvc-env.ps1

Setup-LLVM-Env