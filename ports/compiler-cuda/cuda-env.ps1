function Setup-CUDA-Env {
    param(
        [string]$CUDA_PATH = (Join-Path -Path $PSScriptRoot -ChildPath "../compiler/cuda")
    )

    if (-not $env:CUDA_PATH) {
        # Normalize the path
        $CUDA_PATH = (Resolve-Path -Path $CUDA_PATH).Path
        $env:CUDA_PATH = $CUDA_PATH

        # Update PATH environment variable
        $env:PATH = "$env:PATH;$CUDA_PATH/bin"
    }
}

. .\msvc-env.ps1

Setup-CUDA-Env