vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/avro
    REF "release-${VERSION}"
    SHA512 8cc6ef3cf1e0a919118c8ba5817a1866dc4f891fa95873c0fe1b4b388858fbadee8ed50406fa0006882cab40807fcf00c5a2dcd500290f3868d9d06b287eacb6
    HEAD_REF master
    PATCHES
        fix-cmake.patch
        fix-fmt.patch
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
find_dependency(Boost REQUIRED COMPONENTS filesystem iostreams program_options regex system)
find_dependency(fmt CONFIG)
find_dependency(Snappy)
${cmake_config}
")
else()
    file(WRITE "${CURRENT_PACKAGES_DIR}/share/unofficial-avro-cpp/unofficial-avro-cpp-config.cmake"
"include(CMakeFindDependencyMacro)
find_dependency(Boost REQUIRED COMPONENTS filesystem iostreams program_options regex system)
find_dependency(fmt CONFIG)
${cmake_config}
")
endif()

vcpkg_copy_pdbs()
vcpkg_copy_tools(TOOL_NAMES avrogencpp AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/lang/c++/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
