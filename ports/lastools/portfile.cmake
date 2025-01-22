vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LAStools/LAStools
    REF "v${VERSION}"
    SHA512 cb150562b09c5a79df1e2c730481ceda340f235e1efb7824564d1f95a9981eada087af06bc3907a777a55d315a1521fb8a09249f2aeefd9e40e6c783b9c7a11c
    HEAD_REF master
    PATCHES 
        fix_install_paths_lastools.patch
        fix_include_directories_lastools.patch
        build-tools.diff
        insecure-fprintf.diff
        signed-char.diff
)

vcpkg_check_features(OUT_FEATURE_OPTIONS options
    FEATURES
        tools   BUILD_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
    OPTIONS_DEBUG
        -DBUILD_TOOLS=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/LASlib PACKAGE_NAME laslib)

if(BUILD_TOOLS)
    vcpkg_copy_tools(TOOL_NAMES las2las64 las2txt64 lascopcindex64 lasdiff64 lasindex64 lasinfo64 lasmerge64 lasprecision64 laszip64 txt2las64  AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt" "${SOURCE_PATH}/COPYING.txt")
