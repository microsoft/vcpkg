vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO duckdb/duckdb
        REF v${VERSION}
        SHA512 d9b4cdc798212ddeb518d9c1d8a6640423ac05f9e8ce99855f96c63778a6757079da37fed17ad8ec131b3f28a9f89c3580d2bbacad03d7607d9d9150347f4903
        HEAD_REF main
    PATCHES
        bigobj.patch
        unvendor_icu_and_find_dependency.patch # https://github.com/duckdb/duckdb/pull/16176 + https://github.com/duckdb/duckdb/pull/16197
        extensions.patch
        t-external-icu.patch # from https://github.com/duckdb/duckdb/pull/16676
)

# Remove vendored dependencies which are not properly namespaced
file(REMOVE_RECURSE
    "${SOURCE_PATH}/third_party/catch"
    "${SOURCE_PATH}/third_party/imdb"
    "${SOURCE_PATH}/third_party/snowball"
    "${SOURCE_PATH}/third_party/tpce-tool"
)

if("excel" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH DUCKDB_EXCCEL_SOURCE_PATH
        REPO duckdb/duckdb-excel
        REF f14e7c3beaf379c54b47b996aa896a1d814e1be8
        SHA512 d2e97cfd59fc08d86f6e4a6fe35dc7dd6435ef1750b334d4b422555987d55eef67a9eb1b1859cacc46addd7a6f848de4e5e092d694fc4ccd7cf24fcf8298012e
        HEAD_REF main
        PATCHES
            excel-libname.patch
    )
    file(RENAME "${DUCKDB_EXCCEL_SOURCE_PATH}" "${SOURCE_PATH}/extension/excel")
endif()

if("httpfs" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH DUCKDB_HTTPFS_SOURCE_PATH
        REPO duckdb/duckdb_httpfs
        REF 85ac4667bcb0d868199e156f8dd918b0278db7b9
        SHA512 5790ed795d394dd1b512aac0d1f1dc5976588d93b34381cab1d78c256428f3047682c7b662b1c855d3b19a9dbf99a6c64f32152dba347c18f2a36e19bcc3c5df
        HEAD_REF main
    )
    file(RENAME "${DUCKDB_HTTPFS_SOURCE_PATH}" "${SOURCE_PATH}/extension/httpfs")
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" DUCKDB_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" DUCKDB_BUILD_DYNAMIC)

set(EXTENSION_LIST "autocomplete;excel;httpfs;icu;json;tpcds;tpch")
set(BUILD_EXTENSIONS "")
foreach(EXT ${EXTENSION_LIST})
    if(${EXT} IN_LIST FEATURES)
        list(APPEND BUILD_EXTENSIONS ${EXT})
    endif()
endforeach()
if(NOT "${BUILD_EXTENSIONS}" STREQUAL "")
    set(BUILD_EXTENSIONS_FLAG "-DBUILD_EXTENSIONS='${BUILD_EXTENSIONS}'")
endif()

vcpkg_cmake_configure(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
            -DOVERRIDE_GIT_DESCRIBE=v${VERSION}
            -DDUCKDB_EXPLICIT_VERSION=v${VERSION}
            -DBUILD_UNITTESTS=OFF
            -DBUILD_SHELL=FALSE
            "${BUILD_EXTENSIONS_FLAG}"
            -DENABLE_EXTENSION_AUTOLOADING=1
            -DENABLE_EXTENSION_AUTOINSTALL=1
            -DWITH_INTERNAL_ICU=OFF
            -DENABLE_SANITIZER=OFF
            -DENABLE_THREAD_SANITIZER=OFF
            -DENABLE_UBSAN=OFF
)

vcpkg_cmake_install()

if(EXISTS "${CURRENT_PACKAGES_DIR}/CMake")
    vcpkg_cmake_config_fixup(CONFIG_PATH CMake)
elseif(EXISTS "${CURRENT_PACKAGES_DIR}/lib/cmake/DuckDB")
    vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/DuckDB")
elseif(EXISTS "${CURRENT_PACKAGES_DIR}/lib/cmake/${PORT}")
    vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/include/duckdb/main/capi/header_generation"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/duckdb/storage/serialization")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
