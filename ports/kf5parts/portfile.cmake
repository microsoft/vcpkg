vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kparts
    REF "v${VERSION}"
    SHA512 c7dc3e9bbc8b03c4111d7e5cc170f4cfc295db540b7d79d279a8892e3fcab18b78389ec41ad8200692aa2deb3100c36d6256b4206e506dfbaa52522ee6acb9f7
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

# See ECM/kde-modules/KDEInstallDirs5.cmake
# Relocate .desktop files for next ports
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    list(APPEND KDE_OPTIONS
        -DKDE_INSTALL_KSERVICES5DIR="share/kservices5"
        -DKDE_INSTALL_KSERVICETYPES5DIR="share/kservicetypes5"
    )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        ${FEATURE_OPTIONS}
        ${KDE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/KF5Parts)
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
