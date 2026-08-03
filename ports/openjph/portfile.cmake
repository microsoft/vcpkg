vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aous72/OpenJPH
    REF "${VERSION}"
    SHA512 2dfafe3db360ac177014c4b65ea0b62ea14ccf61714d80dbaa0c01ab2dbc2153f6d26df3d7af5e6b74e298eb72670a7670fca626a37d2fe7e4c224a3256af35a
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

# OpenJPH sets CMAKE_DEBUG_POSTFIX ("d" for MSVC, "_d" for others) but the
# generated .pc file always references -lopenjph. Fix the debug .pc to match
# the actual library name on disk.
if(NOT VCPKG_BUILD_TYPE)
    if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/openjph.pc" "-lopenjph" "-lopenjphd")
    else()
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/openjph.pc" "-lopenjph" "-lopenjph_d")
    endif()
endif()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES ojph_expand ojph_compress ojph_stream_expand AUTO_CLEAN)
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
