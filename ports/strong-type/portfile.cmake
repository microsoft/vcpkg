vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO "rollbear/strong_type"
    REF "v${VERSION}"
    SHA512 c3167896077ad36eacceea2f52558300255fbb25fc71667aed7afb8b5f994e831d17a54b7d2a100faa1d5e76d7e0ec78f7ea8f8e1507db2ecf30d7639076b84b
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "strong_type" CONFIG_PATH "lib/cmake/strong_type")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
