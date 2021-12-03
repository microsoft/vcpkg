vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kplotting
    REF v5.88.0
    SHA512 490eb410fada9c6a830464b309db77d231d0e06b19ac4e99a07b50d0cdc3bdfb13deb8d60863e47f3ccc350c72320f0515c7a52513892fb2bceea9e4f2fb35a4
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE ${SOURCE_PATH}/.clang-format "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME KF5Plotting CONFIG_PATH lib/cmake/KF5Plotting)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/plugins" "${CURRENT_PACKAGES_DIR}/debug/plugins")
file(RENAME "${CURRENT_PACKAGES_DIR}/lib/plugins" "${CURRENT_PACKAGES_DIR}/plugins")

file(INSTALL "${SOURCE_PATH}/LICENSES/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")

