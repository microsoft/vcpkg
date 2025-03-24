vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO duckdb/duckdb
        REF v${VERSION}
        SHA512 7e2ec4f6d6be6d500b148bd845cc51fe8985190eed8ab6f6fe79012c216cad5592ab3329e2df6b091abcc6ea8937d66f47272baead798c7d711e5d73aa9ffaa7
        HEAD_REF main
    PATCHES
        bigobj.patch
        unvendor_icu_and_find_dependency.patch # https://github.com/duckdb/duckdb/pull/16176 + https://github.com/duckdb/duckdb/pull/16197
        httpfs.patch
        t-external-icu.patch # from https://github.com/duckdb/duckdb/pull/16676
        )

# Remove vendored dependencies which are not properly namespaced
file(REMOVE_RECURSE
    "${SOURCE_PATH}/third_party/catch"
    "${SOURCE_PATH}/third_party/imdb"
    "${SOURCE_PATH}/third_party/snowball"
    "${SOURCE_PATH}/third_party/tpce-tool"
)

vcpkg_from_github(
    OUT_SOURCE_PATH DUCKDB_HTTPFS_SOURCE_PATH
    REPO duckdb/duckdb_httpfs
    REF 85ac4667bcb0d868199e156f8dd918b0278db7b9
    SHA512 5790ed795d394dd1b512aac0d1f1dc5976588d93b34381cab1d78c256428f3047682c7b662b1c855d3b19a9dbf99a6c64f32152dba347c18f2a36e19bcc3c5df
    HEAD_REF main
)

file(RENAME "${DUCKDB_HTTPFS_SOURCE_PATH}" "${SOURCE_PATH}/extension/httpfs")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" DUCKDB_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" DUCKDB_BUILD_DYNAMIC)

set(EXTENSION_LIST "autocomplete;httpfs;icu;json;tpcds;tpch")
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
