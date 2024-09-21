vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ArthurSonzogni/FTXUI
    REF "v${VERSION}"
    SHA512 be5ed7f2b3c90a7de874115a131c75c69ad9dd6db4c3bc0cfd7036cfe449b8d16af3df8f1aa1bcb057347bd726837e3f1c42e30a06cf3ad34b50e7bd26ba4883
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DFTXUI_BUILD_EXAMPLES=OFF
        -DFTXUI_ENABLE_INSTALL=ON
        -DFTXUI_BUILD_TESTS=OFF
        -DFTXUI_BUILD_DOCS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
