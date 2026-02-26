vcpkg_download_distfile(ARCHIVE
    URLS "https://archive.apache.org/dist/avro/avro-${VERSION}/avro-src-${VERSION}.tar.gz"
    FILENAME "avro-src-${VERSION}.tar.gz"
    SHA512 0d86bfece0f12f8bc424e27e71e3e6b828c4280fa1a6d7dc7e0d58bff2351f2c1fd3ccb98c1291dfc6c67d9cb5a0bdb7bb9f36ba5bd6b26fa9545f358db42663
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
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
