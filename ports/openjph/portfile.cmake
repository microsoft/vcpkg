vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aous72/OpenJPH
    REF "${VERSION}"
    SHA512 c34a1a568be4f4587bb1e8bee5b3494035bdeca519f411fe0e01a8b48ac3f2ccea9e7acd8b557462a12aae1fa01bd8b678c499c8be0b221f07b59a0636363863
    HEAD_REF master
    PATCHES
        xsi-strerror_r.patch
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
