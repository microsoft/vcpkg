vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oneapi-src/level-zero
    REF "v${VERSION}"
    SHA512 db480ff4b282918bed4d232c53c7fd8e9d2efd3e1351614cef91bae760f7e5811734700a7622e91e1e75df3fd79c91558d18d7a61cdbd2404c04454f216f6533
    HEAD_REF master
    PATCHES
        patches/spdlog_include.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(BUILD_STATIC "-DBUILD_STATIC=ON")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSYSTEM_SPDLOG=ON
        ${BUILD_STATIC}
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
