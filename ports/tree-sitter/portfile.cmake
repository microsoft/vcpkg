if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tree-sitter/tree-sitter
    REF "v${VERSION}"
    SHA512 c8ffa86caf5841208dd2c987c6437111c7514635ebc76e910deb38ba64252caa99ae8453f1acd8af8e167cc2c7fe7194d481cd53533802601b331c60d20f2a49
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
