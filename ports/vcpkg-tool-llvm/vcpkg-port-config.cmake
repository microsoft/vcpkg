include_guard(GLOBAL)
include("${CMAKE_CURRENT_LIST_DIR}/../vcpkg-cmake-get-vars/vcpkg-port-config.cmake")
set(version @VERSION@)
set(arch "")
if("@VCPKG_TARGET_ARCHITECTURE@" STREQUAL "x86")
    set(arch win32)
    set(hash 90225D650EADB0E590A9912B479B46A575D41A19EB5F2DA03C4DC8B032DC0790222F0E3706DFE2A35C0E7747941972AC26CB47D3EB13730DB76168931F37E5F1)
elseif("@VCPKG_TARGET_ARCHITECTURE@" STREQUAL "x64")
    set(arch win64)
    set(hash 2dd6f3eea106f2b905e6658ea5ea12856d17285adbfba055edc2d6b6389c4c2f7aa001df5cb0d8fb84fa7fa47d5035a7fddf276523b472dd55f150ae25938768)
endif()
set(name "LLVM-${version}-${arch}.exe")
set(url "https://github.com/llvm/llvm-project/releases/download/llvmorg-${version}/${name}")

set(output_path "${DOWNLOADS}/LLVM-${version}-${arch}")
vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")
set(search_paths "${output_path}")
if(VCPKG_DETECTED_CMAKE_C_COMPILER_ID MATCHES "Clang" OR VCPKG_DETECTED_CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    cmake_path(GET VCPKG_DETECTED_CMAKE_C_COMPILER PARENT_PATH possible_llvm_bin_dir)
    list(APPEND search_paths "${possible_llvm_bin_dir}")
    cmake_path(GET VCPKG_DETECTED_CMAKE_CXX_COMPILER PARENT_PATH possible_llvm_bin_dir)
    list(APPEND search_paths "${possible_llvm_bin_dir}")
    unset(possible_llvm_bin_dir)
endif()
find_program(CLANG NAMES "clang" PATHS "${search_paths}" ENV LLVMInstallDir PATH_SUFFIXES "bin")
find_program(CLANG_CL NAMES "clang-cl" PATHS "${search_paths}" ENV LLVMInstallDir PATH_SUFFIXES "bin")
cmake_path(GET CLANG PARENT_PATH LLVM_BIN_DIR)
cmake_path(GET LLVM_BIN_DIR PARENT_PATH LLVM_ROOT)

if(NOT CLANG OR NOT CLANG_CL)
    if(VCPKG_DETECTED_CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
        vcpkg_find_acquire_program(7Z)
        vcpkg_download_distfile(archive_path
            URLS "${url}"
            FILENAME "${name}"
            SHA512 "${hash}"
        )
        file(MAKE_DIRECTORY "${output_path}")
        vcpkg_execute_in_download_mode(
                                COMMAND "${7Z}" x "${archive_path}" "-o${output_path}" "-y" "-bso0" "-bsp0"
                                WORKING_DIRECTORY "${output_path}"
                            )
        file(REMOVE_RECURSE "${output_path}/$PLUGINSDIR")
        set(CLANG "${output_path}/bin/clang@VCPKG_EXECUTABLE_SUFFIX@")
        set(CLANG_CL "${output_path}/bin/clang-cl@VCPKG_EXECUTABLE_SUFFIX@")
        cmake_path(GET CLANG PARENT_PATH LLVM_ROOT)
    endif()
endif()
