vcpkg_fail_port_install(ON_ARCH "x86" "arm" "arm64")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/arrow
    REF apache-arrow-3.0.0
    SHA512 02645be0eaaaa69880ab911fc0b74665ebf52a35f9ad05210b23e7b42bcfbe3c3a4d44fa6c4c35af74764efbe528c2e0ebf0549ce5890c796be695ceb94e5606
    HEAD_REF master
    PATCHES
        all.patch
)

string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} "dynamic" ARROW_BUILD_SHARED)
string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} "static" ARROW_BUILD_STATIC)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    "csv"         ARROW_CSV
    "json"        ARROW_JSON
    "parquet"     ARROW_PARQUET
    "filesystem"  ARROW_FILESYSTEM
)

file(REMOVE "${SOURCE_PATH}/cpp/cmake_modules/FindZSTD.cmake")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/cpp
    PREFER_NINJA
    OPTIONS
        -DARROW_DEPENDENCY_SOURCE=SYSTEM
        -Duriparser_SOURCE=SYSTEM
        -DARROW_BUILD_TESTS=OFF
        ${FEATURE_OPTIONS}
        -DARROW_BUILD_STATIC=${ARROW_BUILD_STATIC}
        -DARROW_BUILD_SHARED=${ARROW_BUILD_SHARED}
        -DARROW_BROTLI_USE_SHARED=${ARROW_BUILD_SHARED}     # This can be wrong in custom triplets
        -DARROW_GFLAGS_USE_SHARED=${ARROW_BUILD_SHARED}     # This can be wrong in custom triplets
        -DARROW_LZ4_USE_SHARED=${ARROW_BUILD_SHARED}        # This can be wrong in custom triplets
        -DARROW_SNAPPY_USE_SHARED=${ARROW_BUILD_SHARED}     # This can be wrong in custom triplets
        -DARROW_THRIFT_USE_SHARED=OFF                       # vcpkg doesn't build Thrift as a shared library for the moment (2020/01/22).
        -DARROW_UTF8PROC_USE_SHARED=${ARROW_BUILD_SHARED}   # This can be wrong in custom triplets
        -DARROW_ZSTD_USE_SHARED=${ARROW_BUILD_SHARED}       # This can be wrong in custom triplets
        -DARROW_JEMALLOC=OFF
        -DARROW_BUILD_UTILITIES=OFF
        -DARROW_WITH_BZ2=ON
        -DARROW_WITH_ZLIB=ON
        -DARROW_WITH_ZSTD=ON
        -DARROW_WITH_LZ4=ON
        -DARROW_WITH_SNAPPY=ON
        -DARROW_WITH_BROTLI=ON
        -DARROW_WITH_UTF8PROC=ON
        -DPARQUET_REQUIRE_ENCRYPTION=ON
        -DBUILD_WARNING_LEVEL=PRODUCTION
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/arrow_static.lib)
    message(FATAL_ERROR "Installed lib file should be named 'arrow.lib' via patching the upstream build.")
endif()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/arrow)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
