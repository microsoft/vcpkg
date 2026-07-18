vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ultravideo/uvg266
    REF v${VERSION}
    SHA512 892b0732516fe2639f93b250bbed342da8134deeaa6f0ccb429ff8451df727f971c7ee284fef93eaa431c5c54a8b8789ffc853d8b45ae93433ba17007989bbae
    HEAD_REF master
    PATCHES
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_copy_tools(TOOL_NAMES uvg266 AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
