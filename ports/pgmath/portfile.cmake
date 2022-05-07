#vcpkg_check_linkage(ONLY_STATIC_LIBRARY) # requires same linkage as vcpkg-tool-flang

vcpkg_download_distfile(
    PGMATH_PATCH
    URLS "https://patch-diff.githubusercontent.com/raw/flang-compiler/flang/pull/1167.diff" # stable?
    FILENAME 1167.diff
    SHA512 4a795e59c1c930a1f19963336881134037332eadc8bdd3206205f8affdbac938a177db603bfd03f0783a84be38818e21c8ec09a0f1089252e1328cecd8f26ff1
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  flang-compiler/flang
    REF 0df85a22ae141078658569a0e1b3745afd702e45
    SHA512 f7195fbf0885dd767ff7f8ab48688586f4c9995dc81d619d4a315e3a3a8b1af019232410aa4eff1e85ed910281338dc6ebb54f55d34534c3d92766b6e1a74149
    PATCHES "${PGMATH_PATCH}"
            build_only_one_kind.patch
            werror.patch
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
    OPTIONS ${OPTIONS}
            "-DWITH_WERROR=OFF"
    MAYBE_UNUSED_VARIABLES
            WITH_WERROR

)
vcpkg_cmake_install(ADD_BIN_TO_PATH)

configure_file("${SOURCE_PATH}/runtime/libpgmath/LICENSE.txt" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled) # Build depends on VCPKG_CRT_LINKAGE (maybe introcude VCPKG_FRT_LINKAGE?)
