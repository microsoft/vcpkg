vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/sonnet
    REF v5.87.0
    SHA512 4e4a8d0a31013f617dd6e38f78f56459cbb61fc59c31db0db09ee6a4086bb3913515af502c783a58c6c964168948394063fdabb6906e2cdb99f661dd1f596e4d
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE ${SOURCE_PATH}/.clang-format "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBUILD_TESTING=OFF
        -DKDE_INSTALL_PLUGINDIR=plugins
        -DKDE_INSTALL_QTPLUGINDIR=plugins
)

vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}/bin")
vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}/debug/bin")

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME KF5Sonnet CONFIG_PATH lib/cmake/KF5Sonnet)

vcpkg_copy_tools(
    TOOL_NAMES gentrigrams parsetrigrams
    AUTO_CLEAN
)

file(APPEND "${CURRENT_PACKAGES_DIR}/tools/${PORT}/qt.conf" "Data = ../../share")

vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/gentrigrams${VCPKG_HOST_EXECUTABLE_SUFFIX}")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/parsetrigrams${VCPKG_HOST_EXECUTABLE_SUFFIX}")

file(INSTALL "${SOURCE_PATH}/LICENSES/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")

