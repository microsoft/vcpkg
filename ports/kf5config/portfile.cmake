vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kconfig
    REF "v${VERSION}"
    SHA512 dfd6e09ccaf132745f3bcba6276c6f5d0394c4aa2dd50ac234415e2fca3c5681d1c11e8f4141fdb9dc18aba806922c99dd6195d9013962e11de7c50cc2ca01a7
    HEAD_REF master
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DKDE_INSTALL_LIBEXECDIR=bin
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/KF5Config)
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

file(APPEND "${CURRENT_PACKAGES_DIR}/tools/${PORT}/qt.conf" "Data = ../../share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
