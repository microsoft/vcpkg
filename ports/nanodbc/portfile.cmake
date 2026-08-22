# Only static libraries are supported.
# See https://github.com/nanodbc/nanodbc/issues/13
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nanodbc/nanodbc
    REF 1f7279111c013388509bab4bd0865a929ad02998 # v2.14.0
    SHA512 e71ec290b0f51963a0faa45b92ebfb3409ae27389e4a0cb8bf6616ec40db41f74e3e45668cf8ee852e0a456fbd5d495092d6c337a24ee7b5b6cb0aea496034b6
    HEAD_REF master
    PATCHES
        find-unixodbc.patch
        no-werror.patch
)

if(DEFINED NANODBC_ODBC_VERSION)
    set(NANODBC_ODBC_VERSION -DNANODBC_ODBC_VERSION=${NANODBC_ODBC_VERSION})
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNANODBC_DISABLE_EXAMPLES=ON
        -DNANODBC_DISABLE_TESTS=ON
        -DNANODBC_ENABLE_UNICODE=OFF
        ${NANODBC_ODBC_VERSION}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(CONFIG_PATH cmake)
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
