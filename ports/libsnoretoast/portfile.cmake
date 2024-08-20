vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/snoretoast
    REF v0.8.0
    SHA512 233751b6cc3f8099c742e4412a3c9ba8707a2f3c69b57bab93dd83b028aa0c0656cade8de1ece563843ace576fd0d8e5f3a29c254a07ed939d0a69cd2d4f6c2a
    HEAD_REF master
    PATCHES
        include_fix.patch # https://invent.kde.org/libraries/snoretoast/-/merge_requests/1
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_STATIC_RUNTIME=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME LibSnoreToast CONFIG_PATH "lib/cmake/libsnoretoast")
vcpkg_copy_tools(
    TOOL_NAMES "snoretoast"
    AUTO_CLEAN
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/etc")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(INSTALL "${SOURCE_PATH}/COPYING.LGPL-3" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
