vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vsg-dev/vsgImGui
    REF "v${VERSION}"
    SHA512 1d3e673a718769bb6ea6de723a398712220e9a91fa4ca21bce449613e18cd9ccd0030669db8bbf86c468fa26f7a872acfef194989ccc453e7d60959f697fd000
    HEAD_REF master
    PATCHES
        devendor.patch
        remove-manual-font-creation.patch
)
file(REMOVE "${SOURCE_PATH}/include/vsgImGui/imgui.h")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSHOW_DEMO_WINDOW=OFF
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/vsgImGui")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
