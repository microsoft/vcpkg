vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Sigmyne/xchange
    REF "v${VERSION}"
    SHA512 1de2e387b6f0efbbc0fbfc9e23619fc15d55943b28b6d628c06eaf0787d2d6c36d52069ffa1b5d55f59bba74a7c304bde928aa1acb6315fd0cbc0ac051ee51c6
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/xchange" PACKAGE_NAME "xchange")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
