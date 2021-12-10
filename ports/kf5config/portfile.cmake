vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kconfig
    REF v5.88.0
    SHA512 c38d40bf132868ba8e152aba043580cff137db2d752b5d218e29a71defd5a3f8f681aa56ced3873def7423c429377106ff4a049abaa4721a83df2b83c7fbc2a6
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE ${SOURCE_PATH}/.clang-format "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBUILD_TESTING=OFF
        -DKDE_INSTALL_LIBEXECDIR=bin
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME KF5Config CONFIG_PATH lib/cmake/KF5Config)
vcpkg_copy_pdbs()

vcpkg_copy_tools(
    TOOL_NAMES kreadconfig5 kwriteconfig5
    AUTO_CLEAN
)

if(NOT VCPKG_TARGET_IS_WINDOWS)
    set(LIBEXEC_SUBFOLDER "kf5/")
endif()

vcpkg_copy_tools(
    TOOL_NAMES kconf_update kconfig_compiler_kf5
    SEARCH_DIR "${CURRENT_PACKAGES_DIR}/bin/${LIBEXEC_SUBFOLDER}"
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${LIBEXEC_SUBFOLDER}"
    AUTO_CLEAN
)

file(APPEND ${CURRENT_PACKAGES_DIR}/tools/${PORT}/qt.conf "Data = ../../share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")	
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")	
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSES/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")


