vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libspatialindex/libspatialindex
    REF "${VERSION}"
    SHA512 a508a9ed4019641bdaaa53533505531f3db440b046a9c7d9f78ed480293200c51796c2d826a6bb9b4f9543d60bb0fef9e4c885ec3f09326cfa4d2fb81c1593aa
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    WINDOWS_USE_MSBUILD
    OPTIONS
        -DCMAKE_DEBUG_POSTFIX=d
        -DSIDX_BUILD_TESTS:BOOL=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})  
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

#Debug
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
