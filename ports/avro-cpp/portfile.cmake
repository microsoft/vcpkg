vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/avro
    REF e44b680621328c4e6524bd2983af1ce11afeebed
    SHA512 932f642f272997b5c0be467d3a3ccc354c6edf425c36b33aa7e61984f67312c712bb1d74cb1a5fd8066169104851e73830f0ed3fdb450e005a5c5bef33c34f20
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
