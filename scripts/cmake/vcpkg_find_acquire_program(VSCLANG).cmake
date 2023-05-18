if(NOT CMAKE_HOST_WIN32)
    message(FATAL_ERROR "Visual Studio is only supported on Windows hosts.")
endif()

set(program_name "")
set(paths_to_search
    # LLVM in Visual Studio
    "$ENV{LLVMInstallDir}/x64/bin"
    "$ENV{LLVMInstallDir}/bin"
    "$ENV{VCINSTALLDIR}/Tools/Llvm/x64/bin"
    "$ENV{VCINSTALLDIR}/Tools/Llvm/bin"
)
find_program(VSCLANG
    NAMES clang
    PATHS ${paths_to_search}
    NO_DEFAULT_PATH
)
