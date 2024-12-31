vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nibanks/msh3
    REF #[[ v${VERSION} ]] 3b471e9bef5c486df2f5a3e2d220f5b76d0ba705
    SHA512 9d6da0eb116dd051b7de78aa9edd47af04de05cb1915a3378f7cf96f8497156e486f1ff9ccb55ed02e2d12c1bfd84fd9a962cadcff8a66954102dcdd36b7250d
    HEAD_REF main
    PATCHES
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
vcpkg_copy_tools(TOOL_NAMES msh3app msh3test  AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
