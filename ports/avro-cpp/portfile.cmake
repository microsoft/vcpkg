vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/avro
    REF "release-${VERSION}"
    SHA512 4e7fd7ebb41f6149a499d0d38babd99d07f936143b47a60f7c568a589fb0e6369301c7230bde518b554eaeaa9ded1ed1fae2661cbd5ebc49fb5f22d97c066f05
    HEAD_REF master
    PATCHES
        fix-cmake.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools              AVRO_BUILD_EXECUTABLES
    INVERTED_FEATURES
        snappy             CMAKE_DISABLE_FIND_PACKAGE_Snappy
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/lang/c++"
    OPTIONS
        -DAVRO_BUILD_STATIC=${BUILD_STATIC}
        -DAVRO_BUILD_SHARED=${BUILD_SHARED}
        -DAVRO_BUILD_TESTS=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/avro-cpp")
vcpkg_copy_pdbs()
if(AVRO_BUILD_EXECUTABLES)
    vcpkg_copy_tools(TOOL_NAMES avrogencpp AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/lang/c++/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
