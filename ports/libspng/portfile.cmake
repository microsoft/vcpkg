vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO randy408/libspng
    REF "v${VERSION}"
    SHA512 cd729653599ed97f80d19f3048c1b3bc2ac16f922b3465804b1913bc45d9fc8b28b56bc2121fda36e9d3dcdd12612cced5383313b722a5342b613f8781879f1a
    HEAD_REF master
    PATCHES
        fix-spngconfig-cmake.patch # https://github.com/randy408/libspng/pull/262/
        libspng-pr-286.diff # https://github.com/randy408/libspng/pull/286/
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SPNG_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SPNG_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSPNG_STATIC=${SPNG_BUILD_STATIC}
        -DSPNG_SHARED=${SPNG_BUILD_SHARED}
        -DBUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/spng PACKAGE_NAME spng)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(PC_NAME "spng")
else()
    set(PC_NAME "spng_static")
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/spng/spng.c"
)
