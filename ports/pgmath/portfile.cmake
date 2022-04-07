#vcpkg_check_linkage(ONLY_STATIC_LIBRARY) # requires same linkage as vcpkg-tool-flang

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  flang-compiler/flang
    REF 59c43c4d99ade23d103aaf5299016a1666ceb2e1
    SHA512 467c3a977d5a207a0115ece5db070c9b49c1b57595155d477d25fe0b49453facbc90566b6e5ae7a48038b59bda7481b4ed6cd969628f3019076864be74a3d6a3
    PATCHES 1167.diff
            build_only_one_kind.patch
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR ${PYTHON3} DIRECTORY)
vcpkg_add_to_path(${PYTHON3_DIR})

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    find_program(LIB NAMES lib)
    vcpkg_list(SET OPTIONS 
                "-DCMAKE_C_COMPILER=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/vcpkg-tool-llvm/bin/clang-cl.exe"
                "-DCMAKE_CXX_COMPILER=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/vcpkg-tool-llvm/bin/clang-cl.exe"
                "-DCMAKE_AR=${LIB}"
                "-DCMAKE_LINKER=link.exe"
                "-DCMAKE_MT=mt.exe"
                )
    vcpkg_acquire_msys(MSYS_ROOT PACKAGES gawk bash sed)
    vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")
endif()
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" PGMATH_SHARED)
vcpkg_list(APPEND OPTIONS "-DPGMATH_SHARED=${PGMATH_SHARED}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/runtime/libpgmath"
    OPTIONS ${OPTIONS}
            "-DWITH_WERROR=OFF"

)
vcpkg_cmake_install(ADD_BIN_TO_PATH)

configure_file("${SOURCE_PATH}/runtime/libpgmath/LICENSE.txt" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled) # Build depends on VCPKG_CRT_LINKAGE (maybe introcude VCPKG_FRT_LINKAGE?)
