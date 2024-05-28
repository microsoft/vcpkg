if (Test-Path "$env:ProgramFiles\NVIDIA GPU Computing Toolkit\CUDA\v12.1\include\cudnn.h") {
    Write-Host 'cudnn appears correctly installed'
} else {
    Write-Error 'cudnn appears broken!'
}
