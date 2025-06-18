vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO duckdb/duckdb
        REF v${VERSION}
        SHA512 db92ed9781fe6b88db7e283b188e95ae24a5b567a8e9fd3539574b9fc6c9b3f50330886b8ff9b340f733795115194f624d17eb4cecddc43249dd235ce9201027
        HEAD_REF main
    PATCHES
        extensions.patch
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
        REF 7e97933214d0c7de2315668ec68589ae85651afb
        SHA512 594ffe9456e1c11e3bed2939199e735afcd071f9a1b241a3ab0f6fd85c1cdf89d00d10c380260f86f8b9ab0beb1fb904faf9b4c20869b016c41ce86caac4c185
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
        REF 85a4c0ed07cbda688f71589ed3a92a093bc55c87
        SHA512 f0040a38dae4bcea360f1da53032aea956dcdd31d80fe0b8b6243c041e53f1b7840ed775a7e29ca0bb70010bf954f4cdb1f2274506cbd4bfcfcc5899b9d3f226
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
