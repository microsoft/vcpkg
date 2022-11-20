file(READ "${CURRENT_PORT_DIR}/vcpkg.json" manifest)
string(JSON version GET "${manifest}" version)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/snappy
    REF ${version}
    SHA512 f1f8a90f5f7f23310423574b1d8c9acb84c66ea620f3999d1060395205e5760883476837aba02f0aa913af60819e34c625d8308c18a5d7a9c4e190f35968b024
    HEAD_REF master
    PATCHES
        fix_clang-cl_build.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSNAPPY_BUILD_TESTS=OFF
        -DSNAPPY_BUILD_BENCHMARKS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Snappy)
vcpkg_copy_pdbs()

string(JSON version GET "${manifest}" version)
string(JSON description GET "${manifest}" description)
set(name "${PORT}")

configure_file("${CURRENT_PORT_DIR}/${PORT}.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/${PORT}.pc" @ONLY)
if(NOT VCPKG_BUILD_TYPE)
    configure_file("${CURRENT_PORT_DIR}/${PORT}.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/${PORT}.pc" @ONLY)
endif()


file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
