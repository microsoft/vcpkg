set(program_name clang)
set(tool_subdirectory "clang-21.1.8")
set(program_version 21.1.8)
if(CMAKE_HOST_WIN32)
    set(paths_to_search
        # Support LLVM in Visual Studio 2019
        "$ENV{LLVMInstallDir}/x64/bin"
        "$ENV{LLVMInstallDir}/bin"
        "$ENV{VCINSTALLDIR}/Tools/Llvm/x64/bin"
        "$ENV{VCINSTALLDIR}/Tools/Llvm/bin"
        "${DOWNLOADS}/tools/${tool_subdirectory}-windows/bin"
        "${DOWNLOADS}/tools/clang/${tool_subdirectory}/bin")

    if(DEFINED ENV{PROCESSOR_ARCHITEW6432})
        set(host_arch "$ENV{PROCESSOR_ARCHITEW6432}")
    else()
        set(host_arch "$ENV{PROCESSOR_ARCHITECTURE}")
    endif()

    if(host_arch MATCHES "64")
        set(download_urls "https://github.com/llvm/llvm-project/releases/download/llvmorg-${program_version}/LLVM-${program_version}-win64.exe")
        set(download_filename "LLVM-${program_version}-win64.exe")
        set(download_sha512 69ee513fb41bafd159f33c54fad44739e1c150fee37ddf0d5d4cfd88424b42a9177d828ba2a3f19f1a09a8cf84225bade94681fe075994c83e49cc84e15a0718)
    else()
        set(download_urls "https://github.com/llvm/llvm-project/releases/download/llvmorg-${program_version}/LLVM-${program_version}-win32.exe")
        set(download_filename "LLVM-${program_version}-win32.exe")
        set(download_sha512 6027bfcb5ef680fd34477f2b1dddea3a0b11062ebfa7009b46c1fdcf3d124f28dca41d62e4c6367edd01a12a3b995618ef01acd309538e277f6cb5db98c6164d)
    endif()
endif()
set(brew_package_name "llvm")
set(apt_package_name "clang")
