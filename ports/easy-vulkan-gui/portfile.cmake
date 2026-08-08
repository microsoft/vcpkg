vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            Ai-finder-for-api/easy-vulkan-gui
    REF             main
    SHA512          7de64563e79d5ce1f85d36d9e775244b0857046492b2bfd66bff1ce64ef6e55d18b9588414bf740c3447ebfcd8c785bcff42bd9367fd514d4b5ed0dcfc1bc4c9
    HEAD_REF        main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DVGUI_BUILD_EXAMPLES=OFF
        -DVGUI_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME   vgui
    CONFIG_PATH    lib/cmake/vgui
)

# Remove debug includes (duplicate of release)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")