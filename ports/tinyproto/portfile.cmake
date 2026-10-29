vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lexus2k/tinyproto
    REF v${VERSION}
    SHA512 bc63bf8168ba9fbf951ad56dca5996e96e2a3642052d64f59ef3fd966ea0e5696a054b63d35abf429371ce0facd3071389275154ed3b5bb2aa00ac53c857ef2c
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

