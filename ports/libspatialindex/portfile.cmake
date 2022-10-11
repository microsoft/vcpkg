vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libspatialindex/libspatialindex
    REF 1.9.3
    SHA512 d4c608abbd631dc163b7b4fb6bf09dee3e85ce692a5f8875d51f05a26e09c75cd17dff1ed9d2c232a071f0f5864d21d877b4cbc252f3416896db24dfa3fa18cb
    HEAD_REF master
    PATCHES
        static.patch
        mingw.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DCMAKE_DEBUG_POSTFIX=d
        -DSIDX_BUILD_TESTS:BOOL=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

#Debug
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
