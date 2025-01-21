vcpkg_download_distfile(
    ARCHIVE_PATH
    URLS "https://archive.apache.org/dist/arrow/arrow-${VERSION}/apache-arrow-${VERSION}.tar.gz"
    FILENAME apache-arrow-${VERSION}.tar.gz
    SHA512 7249c03a6097bc64fb0092143e4d4aaef3227565147e6254f026ddd504177c8dd565a184a0df39743dc989070dc3785e5b66f738c8e310ed9c982b61c2ec4914
)
vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE_PATH}
    PATCHES
        0001-msvc-static-name.patch
        0002-thrift.patch
        0003-utf8proc.patch
        0004-android-musl.patch
        0005-android-datetime.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        acero       ARROW_ACERO
        compute     ARROW_COMPUTE
        csv         ARROW_CSV
        cuda        ARROW_CUDA
        dataset     ARROW_DATASET
        filesystem  ARROW_FILESYSTEM
        flight      ARROW_FLIGHT
        flightsql   ARROW_FLIGHT_SQL
        gcs         ARROW_GCS
        jemalloc    ARROW_JEMALLOC
        json        ARROW_JSON
        mimalloc    ARROW_MIMALLOC
        orc         ARROW_ORC
        parquet     ARROW_PARQUET
        parquet     PARQUET_REQUIRE_ENCRYPTION
        s3          ARROW_S3
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    list(APPEND FEATURE_OPTIONS "-DARROW_USE_NATIVE_INT128=OFF")
endif()

string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} "dynamic" ARROW_BUILD_SHARED)
string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} "static" ARROW_BUILD_STATIC)
string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} "dynamic" ARROW_DEPENDENCY_USE_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/cpp"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DARROW_BUILD_SHARED=${ARROW_BUILD_SHARED}
        -DARROW_BUILD_STATIC=${ARROW_BUILD_STATIC}
        -DARROW_BUILD_TESTS=OFF
        -DARROW_DEPENDENCY_SOURCE=SYSTEM
        -DARROW_DEPENDENCY_USE_SHARED=${ARROW_DEPENDENCY_USE_SHARED}
        -DARROW_PACKAGE_KIND=vcpkg
        -DARROW_WITH_BROTLI=ON
        -DARROW_WITH_BZ2=ON
        -DARROW_WITH_LZ4=ON
        -DARROW_WITH_SNAPPY=ON
        -DARROW_WITH_ZLIB=ON
        -DARROW_WITH_ZSTD=ON
        -DBUILD_WARNING_LEVEL=PRODUCTION
        -DCMAKE_SYSTEM_PROCESSOR=${VCPKG_TARGET_ARCHITECTURE}
        -DZSTD_MSVC_LIB_PREFIX=
    MAYBE_UNUSED_VARIABLES
        ZSTD_MSVC_LIB_PREFIX
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/arrow_static.lib")
    message(FATAL_ERROR "Installed lib file should be named 'arrow.lib' via patching the upstream build.")
endif()

if("dataset" IN_LIST FEATURES)
    vcpkg_cmake_config_fixup(
        PACKAGE_NAME arrowdataset
        CONFIG_PATH lib/cmake/ArrowDataset
        DO_NOT_DELETE_PARENT_CONFIG_PATH
    )
endif()

if("acero" IN_LIST FEATURES)
    vcpkg_cmake_config_fixup(
        PACKAGE_NAME arrowacero
        CONFIG_PATH lib/cmake/ArrowAcero
        DO_NOT_DELETE_PARENT_CONFIG_PATH
    )
endif()

if("flight" IN_LIST FEATURES)
    vcpkg_cmake_config_fixup(
        PACKAGE_NAME ArrowFlight
        CONFIG_PATH lib/cmake/ArrowFlight
        DO_NOT_DELETE_PARENT_CONFIG_PATH
    )
endif()

if("flightsql" IN_LIST FEATURES)
    vcpkg_cmake_config_fixup(
        PACKAGE_NAME ArrowFlightSql
        CONFIG_PATH lib/cmake/ArrowFlightSql
        DO_NOT_DELETE_PARENT_CONFIG_PATH
    )
endif()

if("parquet" IN_LIST FEATURES)
    vcpkg_cmake_config_fixup(
        PACKAGE_NAME parquet
        CONFIG_PATH lib/cmake/Parquet
        DO_NOT_DELETE_PARENT_CONFIG_PATH
    )
endif()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Arrow)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
if("parquet" IN_LIST FEATURES)
    file(READ "${CMAKE_CURRENT_LIST_DIR}/usage-parquet" usage-parquet)
    file(APPEND "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" "${usage-parquet}")
endif()
if("dataset" IN_LIST FEATURES)
    file(READ "${CMAKE_CURRENT_LIST_DIR}/usage-dataset" usage-dataset)
    file(APPEND "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" "${usage-dataset}")
endif()
if("acero" IN_LIST FEATURES)
    file(READ "${CMAKE_CURRENT_LIST_DIR}/usage-acero" usage-acero)
    file(APPEND "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" "${usage-acero}")
endif()

if("flight" IN_LIST FEATURES)
    file(READ "${CMAKE_CURRENT_LIST_DIR}/usage-flight" usage-flight)
    file(APPEND "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" "${usage-flight}")
endif()

if("flightsql" IN_LIST FEATURES)
    file(READ "${CMAKE_CURRENT_LIST_DIR}/usage-flightsql" usage-flightsql)
    file(APPEND "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" "${usage-flightsql}")
endif()

if("example" IN_LIST FEATURES)
    file(INSTALL "${SOURCE_PATH}/cpp/examples/minimal_build/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/example")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
