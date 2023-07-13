vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kcoreaddons
    REF v5.98.0
    SHA512 99c86e7931d62b7af6f631103b5d6ea75d70d2977842d4e3962dbc22bbdcfe398484d74d7c58a90bd9e86c738d632a3fd68da8ece42841559e7cc48ee1431ab6
    PATCHES
        0001-Add-support-for-static-builds.patch # https://invent.kde.org/frameworks/kcoreaddons/-/merge_requests/129
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME KF5CoreAddons CONFIG_PATH lib/cmake/KF5CoreAddons)
vcpkg_copy_pdbs()

vcpkg_copy_tools(
    TOOL_NAMES desktoptojson
    AUTO_CLEAN
)

file(APPEND "${CURRENT_PACKAGES_DIR}/tools/${PORT}/qt.conf" "Data = ../../share")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin/data/kf5")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin/data/kf5")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})

