vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kguiaddons
    REF "v${VERSION}"
    SHA512 ad221061698fea27e354ce2be0ec565fd70850add9964c306d415c4cc95b68d09c0c217fde1e45f0ad668a13e93b2a5e2d0059a6bfb514b1cea6f37d4ac01a0f
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

if(NOT "qml" IN_LIST FEATURES)
  list(APPEND FEATURE_OPTIONS "-DCMAKE_DISABLE_FIND_PACKAGE_Qt6Qml=ON")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_PYTHON_BINDINGS=OFF
        -DKDE_INSTALL_QMLDIR=qml
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6Tools=ON
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME kf6guiaddons
    CONFIG_PATH lib/cmake/KF6GuiAddons
)
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig(SKIP_CHECK)

vcpkg_copy_tools(
    TOOL_NAMES kde-geo-uri-handler
    AUTO_CLEAN
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
