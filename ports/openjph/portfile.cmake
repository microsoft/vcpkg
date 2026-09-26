vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aous72/OpenJPH
    REF "${VERSION}"
    SHA512 4207570b05deef8e46ca6d8b2dba0d5fd4a02e3bed8ddcc5d950b4404368505d918a6047c716143a56cd38e8e778f62c046b6472d7ff8bc0a71a2ab694bfdd07
    HEAD_REF master
    PATCHES
        xsi-strerror_r.patch
        fix-pkgconfig-library-name.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools OJPH_BUILD_EXECUTABLES
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DOJPH_ENABLE_TIFF_SUPPORT=ON
        -DOJPH_BUILD_TESTS=OFF
        -DOJPH_BUILD_STREAM_EXPAND=ON
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DOJPH_BUILD_EXECUTABLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/openjph)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES ojph_expand ojph_compress ojph_stream_expand AUTO_CLEAN)
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
