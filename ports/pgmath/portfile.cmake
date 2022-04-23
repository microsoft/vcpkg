#vcpkg_check_linkage(ONLY_STATIC_LIBRARY) # requires same linkage as vcpkg-tool-flang

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  flang-compiler/flang
    REF 5a60d344443e38715b7c837de53d9ce2ed78b0d6
    SHA512 aff012c3cf9756d84b8bb5d0c369a1fd78d51af4cb2734183640e7fdcc16f6e6ab2ab78a56cc4b750f1571f7842b2b76b255e442df98e0aacd5e07db6a9d6a82
    PATCHES 1167.diff
            build_only_one_kind.patch
            werror.patch
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR ${PYTHON3} DIRECTORY)
vcpkg_add_to_path(${PYTHON3_DIR})

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_cmake_get_vars(cmake_vars_file)
    include("${cmake_vars_file}")
    if(VCPKG_DETECTED_CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
        vcpkg_list(SET OPTIONS 
                    "-DCMAKE_C_COMPILER=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/vcpkg-tool-llvm/bin/clang-cl.exe"
                    "-DCMAKE_CXX_COMPILER=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/vcpkg-tool-llvm/bin/clang-cl.exe"
                    "-DCMAKE_AR=${VCPKG_DETECTED_CMAKE_AR}"
                    "-DCMAKE_LINKER=${VCPKG_DETECTED_CMAKE_LINKER}"
                    "-DCMAKE_MT=${VCPKG_DETECTED_CMAKE_MT}"
                    )
        if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
            string(APPEND VCPKG_C_FLAGS " --target=aarch64-win32-msvc")
            string(APPEND VCPKG_CXX_FLAGS " --target=aarch64-win32-msvc")
        endif()
    endif()
    vcpkg_acquire_msys(MSYS_ROOT PACKAGES gawk bash sed)
    vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        vcpkg_list(APPEND OPTIONS -DCMAKE_SYSTEM_PROCESSOR=AMD64)
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        vcpkg_list(APPEND OPTIONS -DCMAKE_CROSSCOMPILING=ON -DCMAKE_SYSTEM_PROCESSOR:STRING=ARM64 -DCMAKE_SYSTEM_NAME:STRING=Windows)
        message(STATUS "OPTIONS:${OPTIONS}" )
    else()
        vcpkg_list(APPEND OPTIONS -DCMAKE_SYSTEM_PROCESSOR=generic 
                                  -DLIBPGMATH_WITH_GENERIC=ON)
    endif()
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" PGMATH_SHARED)
vcpkg_list(APPEND OPTIONS "-DPGMATH_SHARED=${PGMATH_SHARED}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/runtime/libpgmath"
    OPTIONS ${OPTIONS}
            "-DWITH_WERROR=OFF"
    MAYBE_UNUSED_VARIABLES
            WITH_WERROR

)
vcpkg_cmake_install(ADD_BIN_TO_PATH)

configure_file("${SOURCE_PATH}/runtime/libpgmath/LICENSE.txt" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled) # Build depends on VCPKG_CRT_LINKAGE (maybe introcude VCPKG_FRT_LINKAGE?)
