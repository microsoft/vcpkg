set(program_name clang)
set(tool_subdirectory "clang-15.0.6")
set(program_version 15.0.6)
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
        set(download_filename "LLVM-${program_version}-win64.7z.exe")
        set(download_sha512 2dd6f3eea106f2b905e6658ea5ea12856d17285adbfba055edc2d6b6389c4c2f7aa001df5cb0d8fb84fa7fa47d5035a7fddf276523b472dd55f150ae25938768)
    else()
        set(download_urls "https://github.com/llvm/llvm-project/releases/download/llvmorg-${program_version}/LLVM-${program_version}-win32.exe")
        set(download_filename "LLVM-${program_version}-win32.7z.exe")
        set(download_sha512 90225D650EADB0E590A9912B479B46A575D41A19EB5F2DA03C4DC8B032DC0790222F0E3706DFE2A35C0E7747941972AC26CB47D3EB13730DB76168931F37E5F1)
    endif()
endif()
set(brew_package_name "llvm")
set(apt_package_name "clang")
