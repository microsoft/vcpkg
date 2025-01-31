set(DUCKDB_SHORT_HASH 401c8061c6)
vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO duckdb/duckdb
        REF v${VERSION}
        SHA512 ecd036ff975e90c4e9cc3a25784169f5938db19eacd2abc201719d329ec1055608bb2270de22bf409d828196ede6ffe95369154c916916e13a7a14071b05652e
        HEAD_REF master
)

# Remove vendored dependencies which are not properly namespaced
file(REMOVE_RECURSE
    "${SOURCE_PATH}/third_party/catch"
    "${SOURCE_PATH}/third_party/imdb"
    "${SOURCE_PATH}/third_party/snowball"
    "${SOURCE_PATH}/third_party/tpce-tool"
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" DUCKDB_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" DUCKDB_BUILD_DYNAMIC)

set(EXTENSION_LIST "autocomplete;httpfs;icu;json;parquet;tpcds;tpch")
set(EXTENSION_LOAD_LIST "")
foreach(EXT ${EXTENSION_LIST})
    if(${EXT} IN_LIST FEATURES)
        list(APPEND EXTENSION_LOAD_LIST ${EXT})
    endif()
endforeach()
if(NOT "${EXTENSION_LOAD_LIST}" STREQUAL "")
    set(LOAD_EXTENSIONS_FLAG "-DBUILD_EXTENSIONS='${EXTENSION_LOAD_LIST}'")
endif()

if(NOT "parquet" IN_LIST FEATURES)
    set(SKIP_PARQUET_FLAG "-DSKIP_EXTENSIONS=parquet")
endif()

vcpkg_cmake_configure(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
            -DOVERRIDE_GIT_DESCRIBE=v${VERSION}
            -DDUCKDB_EXPLICIT_VERSION=v${VERSION}
            -DBUILD_UNITTESTS=OFF
            -DBUILD_SHELL=FALSE
            "${SKIP_PARQUET_FLAG}"
            "${LOAD_EXTENSIONS_FLAG}"
            -DENABLE_EXTENSION_AUTOLOADING=1
            -DENABLE_EXTENSION_AUTOINSTALL=1
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
