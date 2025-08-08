vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vsg-dev/vsgImGui
    REF "v${VERSION}"
    SHA512 f27ef25edb95c2129553732054080582a6990b6d84ae6f3ff2007489f02cfcb6ce3f728eb56b584315f5e9835daf74d104962b07b35463ba655bf7aa5c99489c
    HEAD_REF master
    PATCHES
        devendor.patch
        remove-manual-font-creation.patch
)

file(REMOVE "${SOURCE_PATH}/include/vsgImGui/imgui.h")

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME "vsgImGui" CONFIG_PATH "lib/cmake/vsgImGui")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
