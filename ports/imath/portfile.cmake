vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AcademySoftwareFoundation/Imath
    REF "v${VERSION}"
    SHA512 32628dfcacb610310b81ffe017a66215cf5fb84c2e0a6ac8c94a68c048be3d2b97eb57965dd253770184d5824cce1e5440b8eefb2834666b273b3193ff108343
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DIMATH_INSTALL_SYM_LINK=OFF
        -DBUILD_TESTING=OFF
        -DIMATH_INSTALL_PKG_CONFIG=ON
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Imath)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
