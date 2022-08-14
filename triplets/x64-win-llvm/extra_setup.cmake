if(DEFINED CURRENT_PORT_DIR AND 
   DEFINED CURRENT_PACKAGES_DIR AND 
   DEFINED CURRENT_BUILDTREES_DIR AND
   DEFINED TARGET_TRIPLET AND
   DEFINED TARGET_TRIPLET_FILE AND
   DEFINED VCPKG_BASE_VERSION AND
   DEFINED VCPKG_MANIFEST_INSTALL AND
   DEFINED CMD)
    # These means we are within vcpkg and not somewhere else.
    #include("${CMAKE_CURRENT_LIST_DIR}/scripts/vcpkg_configure_cmake.cmake") 
    set(ENV{PATH} "${CMAKE_CURRENT_LIST_DIR}/wrappers;$ENV{PATH}")

    if (DEFINED ENV{ProgramW6432})
        file(TO_CMAKE_PATH "$ENV{ProgramW6432}" PROG_ROOT)
    else()
        file(TO_CMAKE_PATH "$ENV{PROGRAMFILES}" PROG_ROOT)
    endif()
    if (DEFINED ENV{LLVMInstallDir})
        file(TO_CMAKE_PATH "$ENV{LLVMInstallDir}/bin" POSSIBLE_LLVM_BIN_DIR)
    else()
        file(TO_CMAKE_PATH "${PROG_ROOT}/LLVM/bin" POSSIBLE_LLVM_BIN_DIR)
    endif()
    unset(PROG_ROOT)
    find_program(CLANG-CL_EXECUTBALE NAMES "clang-cl" "clang-cl.exe" PATHS "${POSSIBLE_LLVM_BIN_DIR}"
                                                                           ENV LLVMInstallDir
                                                                     PATH_SUFFIXES "bin"
                                                                     NO_DEFAULT_PATH)
    unset(POSSIBLE_LLVM_BIN_DIR)
    if(NOT CLANG-CL_EXECUTBALE)
        message(FATAL_ERROR "Unable to find LLVM installation. Please define environment variable LLVMInstallDir and LLVMToolsVersion")
    endif()
    get_filename_component(LLVM_BIN_DIR "${CLANG-CL_EXECUTBALE}" DIRECTORY)
    set(LLVM_PATH_BACKUP "$ENV{PATH}")
    set(ENV{PATH} "${LLVM_BIN_DIR};$ENV{PATH}")
endif()
list(APPEND VCPKG_CMAKE_CONFIGURE_OPTIONS
                "-DVCPKG_PORT=${PORT}"
                "-DCMAKE_TRY_COMPILE_PLATFORM_VARIABLES=VCPKG_PORT") # Add port name for toolchain