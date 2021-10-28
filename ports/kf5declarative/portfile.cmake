vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kdeclarative
    REF v5.84.0
    SHA512 5785c49173ccd22aaed040b2590d0f44b6e138bd5c8980ce0d4a31e2bd364f830a256be3dfb7806d206b2197d882c791f73c60f7c973749c4c3e1c7bbf541822
    HEAD_REF master
    PATCHES
        fix_config_cmake.patch
        dont_force_shared.diff
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        "opengl"    CMAKE_DISABLE_FIND_PACKAGE_EPOXY
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE ${SOURCE_PATH}/.clang-format "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBUILD_TESTING=OFF
        -DKDE_INSTALL_QTPLUGINDIR=plugins
        -DBUNDLE_INSTALL_DIR=bin
        -DKDE_INSTALL_QMLDIR=qml
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES 
        CMAKE_DISABLE_FIND_PACKAGE_EPOXY
        BUNDLE_INSTALL_DIR
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME KF5Declarative CONFIG_PATH lib/cmake/KF5Declarative)
vcpkg_copy_pdbs()

vcpkg_copy_tools(
    TOOL_NAMES kpackagelauncherqml
    AUTO_CLEAN
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSES/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")