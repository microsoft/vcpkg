vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aous72/OpenJPH
    REF "${VERSION}"
    SHA512 1da1cd1d8e7ad361da1f76634dec306d9eab8f5ececc7aa72d64431c1816dbd3001d809e14da089ceeb8daf55efeba737f03f3f0461da91f6e8f8fbea43f9876
    HEAD_REF master
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
