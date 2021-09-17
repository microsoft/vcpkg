vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libssh2/libssh2
    REF 635caa90787220ac3773c1d5ba11f1236c22eae8 #v1.10.0
    SHA512 ccc3328565e6840464345ac4fa093293733f3320e36358e87d18d5eabc7c250e855c03b058703a1c2a7c8e005335c671e3cdf6ee937322edf1c7812026f71534
    HEAD_REF master
    PATCHES 
        0001-Fix-UWP.patch
        fix-dellexport.patch
        fix-pkgconfig.patch
        fix-error-c2065.patch    #fix error C2065: 'HANDLE_FLAG_INHERIT': undeclared identifier
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
        -DENABLE_ZLIB_COMPRESSION=ON
    OPTIONS_DEBUG
        -DENABLE_DEBUG_LOGGING=OFF
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libssh2)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

