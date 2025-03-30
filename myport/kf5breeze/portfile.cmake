vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/breeze
    REF v6.3.3
    SHA512 25dc7dc88e49ba548641c07c1d6a1d3c84099865bd4eda2289951bc086bf3d666f25762db8bf53f47442eb61e2a3b255313395f65b16959d2b5d152362f32a74
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_QT5=ON
        -DBUILD_QT6=OFF
        -DBUILD_TESTING=OFF
        -DKDE_INSTALL_PLUGINDIR=plugins
)

vcpkg_cmake_install()
# vcpkg_cmake_config_fixup(PACKAGE_NAME KF5Breeze5 CONFIG_PATH lib/cmake/KF5Breeze5)
vcpkg_copy_pdbs()

# file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})

