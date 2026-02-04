vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kguiaddons
    REF "v${VERSION}"
    SHA512 3a6c15adc32fe62496b3d7d87c5c6e2465edf77407cf957789aac20199652664686d7272ae06b9b61f82b3cfbd8c515d2781b5db375ef0c0ed82bd73f33aaf70
    HEAD_REF master
    PATCHES
        fix_cmake.patch # https://github.com/microsoft/vcpkg/issues/17607#issuecomment-831518812
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        wayland WITH_WAYLAND
        x11     WITH_X11
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DQtWaylandScanner_EXECUTABLE=${CURRENT_INSTALLED_DIR}/tools/qt5-wayland/bin/qtwaylandscanner
        -DBUNDLE_INSTALL_DIR=bin
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        BUNDLE_INSTALL_DIR
        QtWaylandScanner_EXECUTABLE
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/KF5GuiAddons)
vcpkg_copy_pdbs()

vcpkg_copy_tools(
    TOOL_NAMES kde-geo-uri-handler
    AUTO_CLEAN
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
