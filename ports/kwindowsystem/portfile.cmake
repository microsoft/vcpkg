vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kwindowsystem
    REF "v${VERSION}"
    SHA512 34efcb6df333ce37a90b22ae833b5516bad2e5bbf04cffbe43005f157499be8d8ba6c788fe84715a8535d80a23dea16d2bf1096ec217899fa5637750638159d7
    HEAD_REF master
    PATCHES
        001_guard_ecm_qml_module_include.patch
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

set(KWINDOWSYSTEM_X11 OFF)
set(KWINDOWSYSTEM_WAYLAND OFF)

if(VCPKG_TARGET_IS_LINUX)
    set(KWINDOWSYSTEM_X11 ON)
    set(KWINDOWSYSTEM_WAYLAND ON)
    message(WARNING "${PORT} currently requires the following libraries from the system package manager:\n    libx11-dev libxcb1-dev libxcb-keysyms1-dev libxcb-res0-dev libxcb-icccm4-dev\n    libwayland-dev wayland-protocols libxkbcommon-dev libxkbcommon-x11-dev\n\nThese can be installed on Ubuntu systems via apt-get install libx11-dev libxcb1-dev libxcb-keysyms1-dev libxcb-res0-dev libxcb-icccm4-dev libwayland-dev wayland-protocols libxkbcommon-dev libxkbcommon-x11-dev")
endif()

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        qml KWINDOWSYSTEM_QML
    INVERTED_FEATURES
        translations KF_SKIP_PO_PROCESSING
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DKDE_INSTALL_PLUGINDIR=plugins
        -DKDE_INSTALL_QMLDIR=qml
        -DKWINDOWSYSTEM_X11=${KWINDOWSYSTEM_X11}
        -DKWINDOWSYSTEM_WAYLAND=${KWINDOWSYSTEM_WAYLAND}
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME kf6windowsystem
    CONFIG_PATH lib/cmake/KF6WindowSystem
)
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig(SKIP_CHECK)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
