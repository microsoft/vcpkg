if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tree-sitter/tree-sitter
    REF "v${VERSION}"
    SHA512 e88861271bcd504f79636811c43c0de94483071f1c6f0f57cc590a2e10f921ca24b87ec631bee4d94d1f124a03a4b74f93c4e5fb8653f62bf484517753882cef
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

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE"
    "${SOURCE_PATH}/lib/src/unicode/LICENSE"
)
