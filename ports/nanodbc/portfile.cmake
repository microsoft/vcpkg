# Only static libraries are supported.
# See https://github.com/nanodbc/nanodbc/issues/13
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nanodbc/nanodbc
    REF f212bcb6ce61029e96cc18b98a4cc05198749ada # v2.20.0
    SHA512 4a3c27b31a03db90b6b7cbe21adbc9ee519af43c9bce78aba2d9fe624eea1c689fffa71b791b3c0bc0a77a7f70d2f0ba2f2c685235f01498f88a189956fc9722
    HEAD_REF master
)

if(DEFINED NANODBC_ODBC_VERSION)
    set(NANODBC_ODBC_VERSION -DNANODBC_ODBC_VERSION=${NANODBC_ODBC_VERSION})
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNANODBC_BUILD_EXAMPLES=OFF
        -DNANODBC_BUILD_TESTS=OFF
        -DNANODBC_ENABLE_UNICODE=OFF
        ${NANODBC_ODBC_VERSION}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
