vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kxmlgui
    REF v5.89.0
    SHA512 6180089ff84456830ceddec564014c75127be1bcb996dd5458f86e5d1dfaa3e3b0267e0605dc8a799abe9aa3d3c0f48c805e5f58e754e19a44a20637dbb95044
    HEAD_REF master
)

vcpkg_check_features(
     OUT_FEATURE_OPTIONS FEATURE_OPTIONS
     FEATURES
         designerplugin BUILD_DESIGNERPLUGIN
 )

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DKDE_INSTALL_PLUGINDIR=plugins
        -DKDE_INSTALL_QTPLUGINDIR=plugins
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME KF5XmlGui CONFIG_PATH lib/cmake/KF5XmlGui)
vcpkg_copy_pdbs()

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_copy_tools(
        TOOL_NAMES ksendbugmail
        AUTO_CLEAN
    )
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
