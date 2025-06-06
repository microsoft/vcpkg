vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Curve/rebind
    REF "v${VERSION}"
    SHA512 8c310eba61a65268fb9820aab0529d04900d1e95544e4fbc6c70a004e4cf64152ab8e2b636d6bd5ad16a381dcbad03f303d176848aedd6e3b29e3037371cf624
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})
vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
