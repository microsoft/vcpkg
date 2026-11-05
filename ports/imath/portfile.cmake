vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AcademySoftwareFoundation/Imath
    REF "v${VERSION}"
    SHA512 a89556f178de90e4b3d62b4d3b34f3d3eb6d511c24f70e2c066e15dac1bf0e89908c486d195b0bc2da00292aee800376f8a241b83253c33688dfd85a048a252f
    HEAD_REF main
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

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE.md"
)
