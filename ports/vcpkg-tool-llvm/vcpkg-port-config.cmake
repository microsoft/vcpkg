include_guard(GLOBAL)
include("${CMAKE_CURRENT_LIST_DIR}/../vcpkg-cmake-get-vars/vcpkg-port-config.cmake")


set(version @version@)
set(arch "")
if("@VCPKG_TARGET_ARCHITECTURE@" STREQUAL "x86")
    set(arch win32)
    set(hash 82bebd0c0912fd000602f5961492ada913e3b6cb63001b63e2de3e070a168c65a628ebb1a443403b272210af131240f3a3032e03478037b5a8200cc243f27b74)
elseif("@VCPKG_TARGET_ARCHITECTURE@" STREQUAL "x64")
    set(arch win64)
    set(hash 96916ef4838e2b43debbf6e92c3b3b1a862051348771df9de6c7c1b0d839ef04c057bddde7e59c2f08e1483d7609dd7a5e77616ed1072047404caa974841a668)
endif()
set(name "LLVM-${version}-${arch}.exe")
set(url "https://github.com/llvm/llvm-project/releases/download/llvmorg-${version}/${name}")

set(output_path "${DOWNLOADS}/LLVM-${version}-${arch}")
find_program(CLANG NAMES clang PATHS "${output_path}" PATH_SUFFIXES "bin")
find_program(CLANG_CL NAMES clang-cl PATHS "${output_path}" PATH_SUFFIXES "bin")
cmake_path(GET CLANG PARENT_PATH LLVM_ROOT)

if(NOT CLANG OR NOT CLANG_CL)
    vcpkg_cmake_get_vars(cmake_vars_file)
    include("${cmake_vars_file}")
    if(VCPKG_DETECTED_CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
        include("${CMAKE_CURRENT_LIST_DIR}/../vcpkg-tool-7zip/vcpkg-port-config.cmake") # make sure 7zip is available
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
    elseif(VCPKG_DETECTED_CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        cmake_path(GET VCPKG_DETECTED_CMAKE_C_COMPILER PARENT_PATH LLVM_BIN_DIR)
        cmake_path(GET LLVM_BIN_DIR PARENT_PATH LLVM_ROOT)
        set(CLANG "${LLVM_ROOT}/bin/clang@VCPKG_EXECUTABLE_SUFFIX@")
        set(CLANG_CL "${LLVM_ROOT}/bin/clang-cl@VCPKG_EXECUTABLE_SUFFIX@")
    endif()
endif
