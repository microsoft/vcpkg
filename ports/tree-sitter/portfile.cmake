if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tree-sitter/tree-sitter
    REF "v${VERSION}"
    SHA512 d6b25738ec3881aaddaf20c6db1138500c4cb37dcc95b8b29990371dee14224bc0bb520d479c2df4a2537f06a81bf034798ebc3b0dedcde9f8f92f64a42ec347
    HEAD_REF master
    PATCHES
        unofficial-cmake.diff
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(PACKAGE_NAME "unofficial-tree-sitter")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
