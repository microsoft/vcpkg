if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tree-sitter/tree-sitter
    REF "v${VERSION}"
    SHA512 a626dcea5378774511aa1ef669e4dbada3079440b596882172a676c61e53aa6f701b537e3575851af9e10b1e264da25a9f6487b01f43a896cf1a22d58ca7e623
    HEAD_REF master
    PATCHES
        pkgconfig.diff
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
