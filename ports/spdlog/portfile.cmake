vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gabime/spdlog
    REF "v${VERSION}"
    SHA512 8df117055d19ff21c9c9951881c7bdf27cc0866ea3a4aa0614b2c3939cedceab94ac9abaa63dc4312b51562b27d708cb2f014c68c603fd1c1051d3ed5c1c3087
    HEAD_REF v1.x
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        benchmark SPDLOG_BUILD_BENCH
        fmt       SPDLOG_FMT_EXTERNAL
        wchar     SPDLOG_WCHAR_SUPPORT
    INVERTED_FEATURES
        fmt       SPDLOG_USE_STD_FORMAT
        tz-offset SPDLOG_NO_TZ_OFFSET
)

# SPDLOG_WCHAR_FILENAMES can only be configured in triplet file since it is an alternative (not additive)
if(NOT DEFINED SPDLOG_WCHAR_FILENAMES)
    set(SPDLOG_WCHAR_FILENAMES OFF)
endif()
if(NOT VCPKG_TARGET_IS_WINDOWS AND SPDLOG_WCHAR_FILENAMES)
    message(FATAL_ERROR "Build option 'SPDLOG_WCHAR_FILENAMES' is for Windows.")
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SPDLOG_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DSPDLOG_INSTALL=ON
        -DSPDLOG_BUILD_SHARED=${SPDLOG_BUILD_SHARED}
        -DSPDLOG_WCHAR_FILENAMES=${SPDLOG_WCHAR_FILENAMES}
        -DSPDLOG_BUILD_EXAMPLE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/spdlog)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/spdlog.pc" " -lspdlog" " -lspdlogd")
endif()

# add support for integration other than cmake
if(SPDLOG_FMT_EXTERNAL)
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/spdlog/tweakme.h
        "// #define SPDLOG_FMT_EXTERNAL"
        "#ifndef SPDLOG_FMT_EXTERNAL\n#define SPDLOG_FMT_EXTERNAL\n#endif"
    )
endif()
if(SPDLOG_USE_STD_FORMAT)
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/spdlog/tweakme.h
        "// #define SPDLOG_USE_STD_FORMAT"
	"#ifndef SPDLOG_USE_STD_FORMAT\n#define SPDLOG_USE_STD_FORMAT\n#endif"
    )
endif()
if(SPDLOG_WCHAR_SUPPORT)
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/spdlog/tweakme.h
        "// #define SPDLOG_WCHAR_TO_UTF8_SUPPORT"
        "#ifndef SPDLOG_WCHAR_TO_UTF8_SUPPORT\n#define SPDLOG_WCHAR_TO_UTF8_SUPPORT\n#endif"
    )
endif()
if(SPDLOG_WCHAR_FILENAMES)
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/spdlog/tweakme.h
        "// #define SPDLOG_WCHAR_FILENAMES"
        "#ifndef SPDLOG_WCHAR_FILENAMES\n#define SPDLOG_WCHAR_FILENAMES\n#endif"
    )
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/include/spdlog/fmt/bundled"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
