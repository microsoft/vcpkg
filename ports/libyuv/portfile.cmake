vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://chromium.googlesource.com/libyuv/libyuv
    REF d98915a654d3564e4802a0004add46221c4e4348
    # Check https://chromium.googlesource.com/libyuv/libyuv/+/refs/heads/main/include/libyuv/version.h for a version!
    PATCHES
        cmake.diff
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools BUILD_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DBUILD_TOOLS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES yuvconvert yuvconstants AUTO_CLEAN)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libyuv/basic_types.h" "defined(LIBYUV_USING_SHARED_LIBRARY)" "1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/libyuv-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")
if(VCPKG_DETECTED_CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    file(APPEND "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" [[

Attention:
You are using MSVC to compile libyuv. This build won't compile any
of the acceleration codes, which results in a very slow library.
See workarounds: https://github.com/microsoft/vcpkg/issues/28446
]])
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
