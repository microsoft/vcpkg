vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mysql/mysql-connector-cpp
    REF "${VERSION}"
    SHA512 aa432822d4c9d7f1328bf59e261c362570f6b2237a5a9f730f96f079aba14bdc689f400ab2857c4cdd1dca025eb09eaaf2b26328f3b42d117f24b9182dc2cc0a
    HEAD_REF master
    PATCHES
        fix-static-build8.patch
        export-targets.patch
        dependencies.patch
        protobuf-cmake.patch
        protobuf-source.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        jdbc WITH_JDBC
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/mysql-connector-cpp-config.cmake.in" DESTINATION "${SOURCE_PATH}")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED_LIBS)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATIC_MSVCRT)

# Use mysql-connector-cpp's own build process.
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    WINDOWS_USE_MSBUILD
    OPTIONS
        "-DWITH_SSL=${CURRENT_INSTALLED_DIR}"
        "-DWITH_LZ4=${CURRENT_INSTALLED_DIR}"
        "-DWITH_ZSTD=${CURRENT_INSTALLED_DIR}"
        "-DWITH_ZLIB=${CURRENT_INSTALLED_DIR}"
        "-DProtobuf_DIR=${CURRENT_INSTALLED_DIR}/share/protobuf" # Without these Windows is unable to find protobuf
        "-Dabsl_DIR=${CURRENT_INSTALLED_DIR}/share/absl"
        "-Dutf8_range_DIR=${CURRENT_INSTALLED_DIR}/share/utf8_range"
        "-DProtobuf_PROTOC_EXECUTABLE=${CURRENT_INSTALLED_DIR}/tools/protobuf/protoc"
        -DBUILD_STATIC=${BUILD_STATIC}
        -DSTATIC_MSVCRT=${STATIC_MSVCRT}
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -DWITH_JDBC=${WITH_JDBC}  # the following variables are only used by jdbc
        "-DMYSQL_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include/mysql"
        "-DMYSQL_LIB_DIR=${CURRENT_INSTALLED_DIR}"
        "-DWITH_BOOST=${CURRENT_INSTALLED_DIR}"
        "-DWITH_TESTS=OFF"
    MAYBE_UNUSED_VARIABLES  # and they are windows only
        MYSQL_INCLUDE_DIR
        MYSQL_LIB_DIR
        WITH_BOOST
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-mysql-connector-cpp)

file(REMOVE
    "${CURRENT_PACKAGES_DIR}/INFO_BIN"
    "${CURRENT_PACKAGES_DIR}/INFO_SRC"
    "${CURRENT_PACKAGES_DIR}/debug/INFO_BIN"
    "${CURRENT_PACKAGES_DIR}/debug/INFO_SRC"
    "${CURRENT_PACKAGES_DIR}/INFO_BIN"
    "${CURRENT_PACKAGES_DIR}/mysql-concpp-config.cmake"
    "${CURRENT_PACKAGES_DIR}/mysql-concpp-config-version.cmake"
    "${CURRENT_PACKAGES_DIR}/debug/mysql-concpp-config.cmake"
    "${CURRENT_PACKAGES_DIR}/debug/mysql-concpp-config-version.cmake"
)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
