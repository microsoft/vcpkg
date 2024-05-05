vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vsg-dev/vsgImGui
    REF "v${VERSION}"
    SHA512 8f3fca47ed7fd4b0a43eaff190457a3e1cf20355f69dd5000bd9f01218855f658fd934ec2abe8b768c11d3c1389a652cdafd9f0b589392878e666b4acd86fc70
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
