if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tree-sitter/tree-sitter
    REF "v${VERSION}"
    SHA512 0d26d0699f61fa27b5adbc298ff53f8e0f5b9f2f1b216744200f6f50cff777c9c5a5a5b92304a4d1889fccd9d8a6dd6b7d4947bac907a91850322281f754ea53
    HEAD_REF master
    PATCHES
        unofficial-cmake.diff
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/lib"
)
vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(PACKAGE_NAME "unofficial-tree-sitter")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
