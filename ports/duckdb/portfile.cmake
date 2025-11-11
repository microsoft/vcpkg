vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO duckdb/duckdb
        REF v${VERSION}
        SHA512 4965071888bfd791ddc81ed9eb53cedcd0248b159e6db3492bf5d17557b0f7516aed0840408ff46a06e9a0989a42d7b2a7452fdaf619c8ca44de43e5d1c338b8
        HEAD_REF main
    PATCHES
        library-linkage.diff
)
# Remove vendored dependencies which are optional or not properly namespaced
file(REMOVE_RECURSE
    "${SOURCE_PATH}/extension/third_party/icu"
    "${SOURCE_PATH}/third_party/catch"
    "${SOURCE_PATH}/third_party/imdb"
    "${SOURCE_PATH}/third_party/snowball"
    "${SOURCE_PATH}/third_party/tpce-tool"
)

set(extension_dirs "")

if("excel" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH DUCKDB_EXCEL_SOURCE_PATH
        REPO duckdb/duckdb-excel
        REF 8504be9ec8183e4082141f9359b53a64d3a440b7
        SHA512 295bfe67c2902c09b584bee623dee7db69aad272a00e6bd4038ec65e2d8a977d1ace7261af8f67863c2fae709acc414e290e40f0bad43bae679c0a8639a0d6b5
        HEAD_REF main
        PATCHES
            library-linkage-excel.diff
    )
    list(APPEND extension_dirs "${DUCKDB_EXCEL_SOURCE_PATH}")
    file(WRITE "${SOURCE_PATH}/.github/config/extensions/excel.cmake" "
duckdb_extension_load(excel
    SOURCE_DIR \"${DUCKDB_EXCEL_SOURCE_PATH}\"
    INCLUDE_DIR \"${DUCKDB_EXCEL_SOURCE_PATH}/src/excel/include\"
)
")
endif()

if("httpfs" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH DUCKDB_HTTPFS_SOURCE_PATH
        REPO duckdb/duckdb_httpfs
        REF 0989823e43554e8a00b31959a853e29ab9bd07f9
        SHA512 71461d522aa5338df81931f937ed538b453b274d22e91ad7e0f1a92e4437a29cc869a0f5be3bd5a9abf0045dfd4681a787923ee32374be471483909c0a60a21f
        HEAD_REF main
        PATCHES
            library-linkage-httpfs.diff
    )
    list(APPEND extension_dirs "${DUCKDB_HTTPFS_SOURCE_PATH}")
    file(WRITE "${SOURCE_PATH}/.github/config/extensions/httpfs.cmake" "
duckdb_extension_load(httpfs
    SOURCE_DIR \"${DUCKDB_HTTPFS_SOURCE_PATH}\"
    INCLUDE_DIR \"${DUCKDB_HTTPFS_SOURCE_PATH}/extension/httpfs/include\"
)
")
endif()

if("iceberg" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH DUCKDB_ICEBERG_SOURCE_PATH
        REPO duckdb/duckdb-iceberg
        REF 6b636bff44aeeccf6f6d5b54de6edf280274beea
        SHA512 f8ce593117dd5423fd5445b6fa6c1f3b11ee7c8a2fdb988c3c0208a59d5ed980b941116866f7cb1d0597662e98c03687da071cbc5617c71086eb112621e31748
        HEAD_REF main
    )
    list(APPEND extension_dirs "${DUCKDB_ICEBERG_SOURCE_PATH}")
    file(WRITE "${SOURCE_PATH}/.github/config/extensions/iceberg.cmake" "
duckdb_extension_load(iceberg
    SOURCE_DIR \"${DUCKDB_ICEBERG_SOURCE_PATH}\"
    INCLUDE_DIR \"${DUCKDB_ICEBERG_SOURCE_PATH}/src/include\"
)
")
endif()

set(BUILD_EXTENSIONS "${FEATURES}")
list(FILTER BUILD_EXTENSIONS INCLUDE REGEX "^(autocomplete|excel|httpfs|icu|json|tpcds|tpch)\$")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" EXTENSION_STATIC_BUILD)

if(VCPKG_CROSSCOMPILING AND NOT DEFINED DUCKDB_EXPLICIT_PLATFORM)
    set(DUCKDB_EXPLICIT_PLATFORM "")
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(DUCKDB_EXPLICIT_PLATFORM "arm64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(DUCKDB_EXPLICIT_PLATFORM "amd64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(DUCKDB_EXPLICIT_PLATFORM "i686")
    endif()
    if(DUCKDB_EXPLICIT_PLATFORM)
        if(VCPKG_TARGET_IS_ANDROID)
            string(APPEND DUCKDB_EXPLICIT_PLATFORM "-linux_android")
        elseif(VCPKG_TARGET_IS_FREEBSD)
            string(APPEND DUCKDB_EXPLICIT_PLATFORM "-freebsd")
        elseif(VCPKG_TARGET_IS_LINUX)
            string(APPEND DUCKDB_EXPLICIT_PLATFORM "-linux")
        elseif(VCPKG_TARGET_IS_OSX)
            string(APPEND DUCKDB_EXPLICIT_PLATFORM "-osx")
        elseif(VCPKG_TARGET_IS_WINDOWS)
            string(APPEND DUCKDB_EXPLICIT_PLATFORM "-windows")
            if(VCPKG_TARGET_IS_MINGW)
                string(APPEND DUCKDB_EXPLICIT_PLATFORM "_mingw")
            endif()
        elseif()
            set(DUCKDB_EXPLICIT_PLATFORM "") # unknown. override in triplet file.
        endif()
    endif()
endif()

vcpkg_cmake_configure(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
            -DOVERRIDE_GIT_DESCRIBE=v${VERSION}-0-g0123456789
            -DDUCKDB_EXPLICIT_PLATFORM=${DUCKDB_EXPLICIT_PLATFORM}
            -DDUCKDB_EXPLICIT_VERSION=v${VERSION}
            "-DBUILD_EXTENSIONS=${BUILD_EXTENSIONS}"
            -DBUILD_SHELL=FALSE
            -DBUILD_UNITTESTS=OFF
            -DCMAKE_JOB_POOL_LINK=console # Serialize linking to avoid OOM
            -DENABLE_EXTENSION_AUTOINSTALL=1
            -DENABLE_EXTENSION_AUTOLOADING=1
            -DENABLE_SANITIZER=OFF
            -DENABLE_THREAD_SANITIZER=OFF
            -DENABLE_UBSAN=OFF
            "-DEXTENSION_CONFIG_BASE_DIR=${SOURCE_PATH}/OUT_OF_TREE"
            "-DEXTENSION_STATIC_BUILD=${EXTENSION_STATIC_BUILD}"
            "-DINSTALL_CMAKE_DIR:STRING=share/${PORT}"
            -DWITH_INTERNAL_ICU=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    foreach(path IN ITEMS duckdb.h duckdb/common/winapi.hpp)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/${path}" "#ifdef DUCKDB_STATIC_BUILD" "#if 1")
    endforeach()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
# empty dirs
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/duckdb/main/capi/header_generation")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/duckdb/storage/serialization")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

set(third_party_licenses "")
file(COPY_FILE "${SOURCE_PATH}/third_party/thrift/thrift/LICENSE" "${SOURCE_PATH}/third_party/thrift/LICENSE")
file(GLOB third_party_files "${SOURCE_PATH}/third_party/*")
foreach(maybe_directory IN LISTS extension_dirs third_party_files)
    if(IS_DIRECTORY "${maybe_directory}")
        cmake_path(GET maybe_directory FILENAME package)
        set(license_file "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/## ${package} license")
        file(COPY_FILE "${maybe_directory}/LICENSE" "${license_file}")
        list(APPEND third_party_licenses "${license_file}")
    endif()
endforeach()
vcpkg_install_copyright(
    COMMENT [[
Duckdb contains copyies of many third-party packages which are subject to
separate license terms.
]]
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        ${third_party_licenses}
)
