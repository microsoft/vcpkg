vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/knewstuff
    REF v5.98.0
    SHA512 dadbd4bcd6408e6b8afba4155a164563b2f3303162edd2f9cd193ab6e6677ce857e4455ccffee8ee289b1c8e634d7b3e5fe1e842efc4c89e67bd25ea103a9f50
    HEAD_REF master
    PATCHES
        0001-Fix-KF5NewStuffWidgets_EXPORTS-is-not-defined-on-cla.patch
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DKDE_INSTALL_QMLDIR=qml
        -DBUNDLE_INSTALL_DIR=bin
    MAYBE_UNUSED_VARIABLES
        BUNDLE_INSTALL_DIR
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME KF5NewStuff CONFIG_PATH lib/cmake/KF5NewStuff DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(PACKAGE_NAME KF5NewStuffCore CONFIG_PATH lib/cmake/KF5NewStuffCore DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(PACKAGE_NAME KF5NewStuffQuick CONFIG_PATH lib/cmake/KF5NewStuffQuick)
vcpkg_copy_pdbs()

vcpkg_copy_tools(
    TOOL_NAMES knewstuff-dialog
    AUTO_CLEAN
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/data/kf5/kmoretools/presets-kmoretools/_README.md")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/data/kf5/kmoretools/presets-kmoretools/_README.md")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})

