vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO atrexus/wincpp
    REF "v${VERSION}"
    SHA512 43674f7e899ce1d4088ad76f4f224c8202aa6af508211cbbae69366ca6467cf61520e0c65d852d0ad805045e9b3d69d414b6ba434d4c8b64becac120d28df294
    HEAD_REF main
    PATCHES
        fix-install-and-w32.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
	-DBUILD_PACKAGE=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
