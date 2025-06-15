vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO seanchas116/qtimgui
    REF 48d64a715b75dee24e398f7e5b0942c2ca329334
    SHA512 072d730f907c876297611736d76e738ab3d2cef968a6ca59d799a487357a998d9841ce2973ccb0880851740e1149e8c6bdd989527b5b3f505bce1c3330d6b901
    HEAD_REF master
    PATCHES
        0001-cmake-files.patch
        0002-fix-keymap.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DQTIMGUI_BUILD_IMGUI=OFF
        -DQTIMGUI_BUILD_IMPLOT=OFF
        -DQTIMGUI_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-qtimgui)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
