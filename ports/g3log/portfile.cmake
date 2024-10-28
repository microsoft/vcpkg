vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KjellKod/g3log
    REF "${VERSION}"
    SHA512 f48c5bb30d734fc218a5bfb19a406101c89deaee4a2f76b21c7105215a29f558efc2759ee1c1664f62cb37e2d8ae0666f99fdce9b863221e4a9efc9814cdf30c
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" G3_SHARED_LIB)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "dynamic" G3_SHARED_RUNTIME)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DG3_SHARED_LIB=${G3_SHARED_LIB} # Options.cmake
        -DG3_SHARED_RUNTIME=${G3_SHARED_RUNTIME} # Options.cmake
        -DADD_FATAL_EXAMPLE=OFF
        -DADD_G3LOG_BENCH_PERFORMANCE=OFF
        -DADD_G3LOG_UNIT_TEST=OFF
        -DVERSION=${VERSION}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/g3log)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
