vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lexus2k/tinyproto
    REF v${VERSION}
    SHA512 32b21822d5516a46ae931b0a4455a212d9b6b7c5a04f6c20b16fa5ce751707cf93a4478ef62262e0478acb076e1ac627ba62e591c07175b63906d9881df64704
    HEAD_REF master
    PATCHES
        fix-deprecated.patch
)

vcpkg_cmake_configure(
	SOURCE_PATH "${SOURCE_PATH}"
	OPTIONS "-DCMAKE_CXX_STANDARD=11"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/tinyproto")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

