vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aklomp/base64
    REF "v${VERSION}"
    SHA512 9f8ca8a6e9feb8ad98158d675ec3331e83c77401d2633de0e43b62e794682a9d63c03e1c2599981ad3cdb249e263964f6a79084dbdf2ca19a1e1eed6195a98f4
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBASE64_BUILD_CLI=OFF
        -DBASE64_REGENERATE_TABLES=OFF
        -DBASE64_WERROR=OFF
        -DBASE64_WITH_OpenMP=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(
	PACKAGE_NAME base64
	CONFIG_PATH "lib/cmake/base64"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
