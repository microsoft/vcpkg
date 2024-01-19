vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO asmaloney/libE57Format
    REF "v${VERSION}"
    SHA512 8a788411a7f02c76c6befe96f09f4ac91c87fc0506a543fb64af4d68330c84d84229560128b1ccb64a0463d2529bc5d486b4af81e534710382e189ef9f1f98cd
    HEAD_REF master
    PATCHES
        prevent_warning_as_errors.diff # see https://github.com/asmaloney/libE57Format/issues/256
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DE57_BUILD_TEST=OFF
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME E57Format CONFIG_PATH "lib/cmake/E57Format")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/libe57format RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
