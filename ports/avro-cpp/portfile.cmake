vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/avro
    REF "release-${VERSION}"
    SHA512 728609f562460e1115366663ede2c5d4acbdd6950c1ee3e434ffc65d28b72e3a43c3ebce93d0a8459f0c4f6c492ebb9444e2127a0385f38eb7cdf74b28f0c3ed
    HEAD_REF master
    PATCHES
        fix-cmake.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        snappy             CMAKE_DISABLE_FIND_PACKAGE_Snappy
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/lang/c++"
    OPTIONS
        -DBUILD_TESTING=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-${PORT})

file(READ "${CURRENT_PACKAGES_DIR}/share/unofficial-avro-cpp/unofficial-avro-cpp-config.cmake" cmake_config)
if("snappy" IN_LIST FEATURES)
    file(WRITE "${CURRENT_PACKAGES_DIR}/share/unofficial-avro-cpp/unofficial-avro-cpp-config.cmake"
"include(CMakeFindDependencyMacro)
find_dependency(ZLIB)
find_dependency(Snappy)
${cmake_config}
")
else()
    file(WRITE "${CURRENT_PACKAGES_DIR}/share/unofficial-avro-cpp/unofficial-avro-cpp-config.cmake"
"include(CMakeFindDependencyMacro)
find_dependency(ZLIB)
${cmake_config}
")
endif()

vcpkg_copy_pdbs()
vcpkg_copy_tools(TOOL_NAMES avrogencpp AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/lang/c++/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
