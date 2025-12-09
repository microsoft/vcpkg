vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LAStools/LAStools
    REF "v${VERSION}"
    SHA512 a44e6df02b8f7fe8388420fc7d454b035c38bcfb43a59d15ecb634cb30165c70730258b8ea79f335c4625b482827feb8a3d7afa8e07b369c19d5f7cc7be15001
    HEAD_REF master
    PATCHES
        fix_install_paths_lastools.patch
        fix_include_directories_lastools.patch
        build_tools.diff
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS_RELEASE
    FEATURES
        tools   BUILD_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_RELEASE
        ${FEATURE_OPTIONS_RELEASE}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/LASlib PACKAGE_NAME laslib)

if(BUILD_TOOLS)
    vcpkg_copy_tools(TOOL_NAMES las2las64 las2txt64 lascopcindex64 lasdiff64 lasindex64 lasinfo64 lasmerge64 lasprecision64 laszip64 txt2las64 AUTO_CLEAN)

    # Copy CSV files that are used as lookup tables by las2las.
    file(COPY "${SOURCE_PATH}/bin/serf/geo" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/serf")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt" "${SOURCE_PATH}/COPYING.txt")
