vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kdeclarative
    REF "v${VERSION}"
    SHA512 a78a59ceec2c89178b15a1892a54a2cb04ffc02df7c60ccf2da142492e4d37f6e4676b06d882c91532082c7647d05af10dd032792b6cc1e5f044eb8eba80c72f
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        "opengl" CMAKE_DISABLE_FIND_PACKAGE_EPOXY
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

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
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/KF5Declarative)
vcpkg_copy_pdbs()

vcpkg_copy_tools(TOOL_NAMES kpackagelauncherqml AUTO_CLEAN)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
