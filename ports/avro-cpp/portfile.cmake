vcpkg_download_distfile(ARCHIVE
    URLS "https://archive.apache.org/dist/avro/avro-${VERSION}/avro-src-${VERSION}.tar.gz"
    FILENAME "avro-src-${VERSION}.tar.gz"
    SHA512 a31ad410d75c0e7f58fc9d9b7e7989dae12f328524806f6d64fdae22ddb9112fe2adc5fb74ee83df2135b87bd6618e8765a823220b2a0a162d1684192b9926da
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
        zstd               CMAKE_DISABLE_FIND_PACKAGE_zstd
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

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/lang/c++/LICENSE"
        "${SOURCE_PATH}/lang/c++/NOTICE"
)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
