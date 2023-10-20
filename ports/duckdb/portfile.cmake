set(DUCKDB_VERSION v0.9.1)
set(DUCKDB_SHORT_HASH 401c8061c6)
vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO duckdb/duckdb
        REF ${DUCKDB_VERSION}
        SHA512 5905d9f619618ba3d0d729424659a81b82809603747582aad9d568e2db1dc719a4e1d336e4a8f602ee0b01ab2b28caa99c242db4b13444150ca593f1d1e4006a
        HEAD_REF master
        PATCHES
            fix_config_file_path.patch
            set_third_party_libs_to_obj.patch
            add_version_pass_through.patch
            add_template_specialization.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" DUCKDB_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" DUCKDB_BUILD_DYNAMIC)

set(EXTENSION_LIST "autocomplete;fts;httpfs;inet;icu;json;parquet;sqlsmith;tpcds;tpch")
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
            -DDUCKDB_OVERWRITE_COMMIT_ID=${DUCKDB_SHORT_HASH}
            -DDUCKDB_OVERWRITE_VERSION=${DUCKDB_VERSION}
            -DBUILD_UNITTESTS=OFF
            -DBUILD_SHELL=FALSE
            "${SKIP_PARQUET_FLAG}"
            "${LOAD_EXTENSIONS_FLAG}"
            -DENABLE_EXTENSION_AUTOLOADING=1
            -DENABLE_EXTENSION_AUTOINSTALL=1
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/duckdb/storage/serialization")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)