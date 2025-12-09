vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libspatialindex/libspatialindex
    REF "${VERSION}"
    SHA512 564af5b443c8d8231a026d59154cfaba939ecc1d555f4108e305645c5290c75bd4ed4286bd296dc12a7f2a0c05192b803e3f3c120538bac676e2f5bccdf034ba
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
