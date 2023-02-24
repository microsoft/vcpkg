#vcpkg_check_linkage(ONLY_STATIC_LIBRARY) # requires same linkage as vcpkg-tool-flang

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    #set(PATCHES clang-cl-flags.patch)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  flang-compiler/flang
    REF 2d211cfe258c23cdc197cba8c4df1e6a116b9764
    SHA512 a7b4c7959f086d0d0bbc6b775d714d6dbe355c3cd3a389f815df3e87aee6850f3a278896b2ba8ffb0a3b022d8c9a6bea6ebce0b5cc505fc41b511ebc033dc7d8
    PATCHES ${PATCHES}
            build_only_one_kind.patch
            #werror.patch
)

vcpkg_find_acquire_program(PYTHON3)
cmake_path(GET PYTHON3 PARENT_PATH PYTHON3_DIR) 
vcpkg_add_to_path("${PYTHON3_DIR}")

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_cmake_get_vars(cmake_vars_file)
    include("${cmake_vars_file}")
    if(VCPKG_DETECTED_CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
        vcpkg_list(SET OPTIONS 
                    "-DCMAKE_C_COMPILER=${CLANG_CL}"
                    "-DCMAKE_CXX_COMPILER=${CLANG_CL}"
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
        vcpkg_list(APPEND OPTIONS -DCMAKE_CROSSCOMPILING=ON)
    else()
        vcpkg_list(APPEND OPTIONS -DCMAKE_SYSTEM_PROCESSOR=generic 
                                  -DLIBPGMATH_WITH_GENERIC=ON)
    endif()
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" PGMATH_SHARED)
vcpkg_list(APPEND OPTIONS "-DPGMATH_SHARED=${PGMATH_SHARED}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/runtime/libpgmath"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS ${OPTIONS}
            "-DWITH_WERROR:BOOL=OFF"
    MAYBE_UNUSED_VARIABLES
            WITH_WERROR

)
vcpkg_cmake_install(ADD_BIN_TO_PATH)

configure_file("${SOURCE_PATH}/runtime/libpgmath/LICENSE.txt" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled) # Build depends on VCPKG_CRT_LINKAGE (maybe introcude VCPKG_FRT_LINKAGE?)
