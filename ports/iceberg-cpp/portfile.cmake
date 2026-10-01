vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/iceberg-cpp
    REF "v${VERSION}"
    SHA512 15bdfa8804a54d2e2f0b559c2562002ee0f67c0bbfb0b7916fa51e1e9cf49ed1362f5265e683e53b2992c81873247ab9dc0e10c57295456f17e72cc4b550178a
    HEAD_REF main
    PATCHES
        avro-1.12.patch
        fix-avro-dependency.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ICEBERG_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ICEBERG_BUILD_SHARED)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        bundle  ICEBERG_BUILD_BUNDLE
        rest    ICEBERG_BUILD_REST
        s3      ICEBERG_S3
        sigv4   ICEBERG_SIGV4
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        --compile-no-warning-as-error
        -DICEBERG_BUILD_STATIC=${ICEBERG_BUILD_STATIC}
        -DICEBERG_BUILD_SHARED=${ICEBERG_BUILD_SHARED}
        -DICEBERG_BUILD_TESTS=OFF
        -DICEBERG_BUILD_BENCHMARKS=OFF
        -DICEBERG_BUILD_HIVE=OFF
        -DICEBERG_BUILD_SQL_CATALOG=OFF
        -DICEBERG_BUNDLE_AWSSDK=OFF
        -DICEBERG_BUNDLE_THRIFT=OFF
        -DICEBERG_SPDLOG=ON
        -DFETCHCONTENT_TRY_FIND_PACKAGE_MODE=ALWAYS
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME iceberg CONFIG_PATH lib/cmake/iceberg)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${SOURCE_PATH}/NOTICE")
