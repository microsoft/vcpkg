# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chusitoo/flatbush
    REF "v${VERSION}"
    SHA512 2acbf3ee56cd265aff5988ed63e2db4320f65beeb5e50f45ad0e028d14f7d41962d25cd40ce56db35a693d9e110f47fc76c1cf45f60a6aeb4cd01719e8b31009
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/flatbush)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
