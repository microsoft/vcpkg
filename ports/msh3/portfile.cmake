vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nibanks/msh3
    REF #[[ v${VERSION} ]] d8063e68e0d03ec63cccb20e3551420bbf7ab04f
    SHA512 f8c0fd8fd8844be67744c83d3a191946a9264f4760c1003517b81f988b1bac51c09badb9e37d294a6a4c0bfa4b67dea38c5e43f6a71c742d2d217007225385cf
    HEAD_REF main
    PATCHES
        msquic.diff
        win32-crt.diff
        wip.diff
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMSH3_INSTALL_PKGCONFIG=ON
        -DMSH3_USE_EXTERNAL_LSQPACK=ON
        -DMSH3_USE_EXTERNAL_MSQUIC=ON
        # WIP
        -DMSH3_TEST=ON
        -DMSH3_TOOL=ON
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup()

# WIP
vcpkg_copy_tools(TOOL_NAMES msh3app msh3test  AUTO_CLEAN  SEARCH_DIR "${CURRENT_PACKAGES_DIR}/debug/lib"  DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug")
vcpkg_copy_tools(TOOL_NAMES msh3app msh3test  AUTO_CLEAN  SEARCH_DIR "${CURRENT_PACKAGES_DIR}/lib")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
