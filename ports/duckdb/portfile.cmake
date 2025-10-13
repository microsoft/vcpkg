vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO duckdb/duckdb
        REF v${VERSION}
        SHA512 4965071888bfd791ddc81ed9eb53cedcd0248b159e6db3492bf5d17557b0f7516aed0840408ff46a06e9a0989a42d7b2a7452fdaf619c8ca44de43e5d1c338b8
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
        REF 8504be9ec8183e4082141f9359b53a64d3a440b7
        SHA512 295bfe67c2902c09b584bee623dee7db69aad272a00e6bd4038ec65e2d8a977d1ace7261af8f67863c2fae709acc414e290e40f0bad43bae679c0a8639a0d6b5
        HEAD_REF main
    )
    file(RENAME "${DUCKDB_EXCCEL_SOURCE_PATH}" "${SOURCE_PATH}/extension/excel")
endif()

if("httpfs" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH DUCKDB_HTTPFS_SOURCE_PATH
        REPO duckdb/duckdb_httpfs
        REF 0989823e43554e8a00b31959a853e29ab9bd07f9
        SHA512 71461d522aa5338df81931f937ed538b453b274d22e91ad7e0f1a92e4437a29cc869a0f5be3bd5a9abf0045dfd4681a787923ee32374be471483909c0a60a21f
        HEAD_REF main
    )
    file(RENAME "${DUCKDB_HTTPFS_SOURCE_PATH}" "${SOURCE_PATH}/extension/httpfs")
endif()

if("iceberg" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH DUCKDB_HTTPFS_SOURCE_PATH
        REPO duckdb/duckdb-iceberg
        REF 6b636bff44aeeccf6f6d5b54de6edf280274beea
        SHA512 f8ce593117dd5423fd5445b6fa6c1f3b11ee7c8a2fdb988c3c0208a59d5ed980b941116866f7cb1d0597662e98c03687da071cbc5617c71086eb112621e31748
        HEAD_REF main
    )
    file(RENAME "${DUCKDB_HTTPFS_SOURCE_PATH}" "${SOURCE_PATH}/extension/iceberg")
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
            -DOVERRIDE_GIT_DESCRIBE=v${VERSION}-0-g0123456789
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
