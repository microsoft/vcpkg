vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gabime/spdlog
    REF v1.10.0
    SHA512 e82ec0a0c813ed2f1c8a31a0f21dbb733d0a7bd8d05284feae3bd66040bc53ad47a93b26c3e389c7e5623cfdeba1854d690992c842748e072aab3e6e6ecc5666
    HEAD_REF v1.x
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        benchmark SPDLOG_BUILD_BENCH
        wchar     SPDLOG_WCHAR_SUPPORT
)

# configured in triplet file
if(NOT DEFINED SPDLOG_WCHAR_FILENAMES)
    set(SPDLOG_WCHAR_FILENAMES OFF)
endif()
if(NOT VCPKG_TARGET_IS_WINDOWS)
    if("wchar" IN_LIST FEATURES)
        message(WARNING "Feature 'wchar' is only supported for Windows and has no effect on other platforms.")
    elseif(SPDLOG_WCHAR_FILENAMES) 
        message(FATAL_ERROR "Build option 'SPDLOG_WCHAR_FILENAMES' is for Windows.")
    endif()
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SPDLOG_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
        -DSPDLOG_FMT_EXTERNAL=ON
        -DSPDLOG_INSTALL=ON
        -DSPDLOG_BUILD_SHARED=${SPDLOG_BUILD_SHARED}
        -DSPDLOG_WCHAR_FILENAMES=${SPDLOG_WCHAR_FILENAMES}
        -DSPDLOG_BUILD_EXAMPLE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/spdlog)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

# use vcpkg-provided fmt library (see also option SPDLOG_FMT_EXTERNAL above)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/spdlog/fmt/bundled)

vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/spdlog/tweakme.h
    "// #define SPDLOG_FMT_EXTERNAL"
    "#define SPDLOG_FMT_EXTERNAL"
)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include
                    ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
