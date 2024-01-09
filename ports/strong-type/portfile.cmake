vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO "rollbear/strong_type"
    REF "v${VERSION}"
    SHA512 "ad8302b3c22404f4a12ae49fd1099ad89d1a66f6354b5e751149ce9f739466a279493931b338f9e933817782d58c795cb43afb47af7f9a214212bf85ba7c6235"
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "strong_type" CONFIG_PATH "lib/cmake/strong_type")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
