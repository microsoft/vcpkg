vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kguiaddons
    REF v5.87.0
    SHA512 20d55c05d5cc2223667a6ca888c7d3e61ec3e1b0f576f0aeff57fce13edb763910fb0bb84d93f53d3965d4a48169fd0fdf2cb5f49946b0e32b25ba4d7645123b
    HEAD_REF master
    PATCHES
        fix_cmake.patch # https://github.com/microsoft/vcpkg/issues/17607#issuecomment-831518812
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        wayland   WITH_WAYLAND
)

if("wayland" IN_LIST FEATURES AND NOT VCPKG_TARGET_IS_LINUX)
    message(FATAL_ERROR "Feature wayland is only supported on Linux.")
endif()

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE ${SOURCE_PATH}/.clang-format "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBUILD_TESTING=OFF
        -DQtWaylandScanner_EXECUTABLE=${CURRENT_INSTALLED_DIR}/tools/qt5-wayland/bin/qtwaylandscanner
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        QtWaylandScanner_EXECUTABLE
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME KF5GuiAddons CONFIG_PATH lib/cmake/KF5GuiAddons)
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSES/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")

