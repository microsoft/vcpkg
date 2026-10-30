vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kidletime
    REF "v${VERSION}"
    SHA512 82257f8d060cf3ac2229e5eaad98765f1773bc19312698e0e533addfec76620f880d21987044177d2efe42bd48988b0a7033560b500e5cbe7cc960c1741fa682
    HEAD_REF master
    PATCHES
        optional-examples.patch
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

if(VCPKG_TARGET_IS_LINUX)
    list(APPEND FEATURE_OPTIONS -DWITH_X11=ON -DWITH_WAYLAND=ON)
    message(WARNING "${PORT} currently requires the following libraries from the system package manager:\n    libx11-dev libx11-xcb-dev libxext-dev libxcb1-dev libxcb-sync-dev libwayland-dev\n\nThese can be installed on Ubuntu systems via apt-get install libx11-dev libx11-xcb-dev libxext-dev libxcb1-dev libxcb-sync-dev libwayland-dev")
else()
    list(APPEND FEATURE_OPTIONS -DWITH_X11=OFF -DWITH_WAYLAND=OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_EXAMPLES=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6Tools=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6ToolsTools=ON
        -DKDE_INSTALL_PLUGINDIR=plugins
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME kf6idletime CONFIG_PATH lib/cmake/KF6IdleTime)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
