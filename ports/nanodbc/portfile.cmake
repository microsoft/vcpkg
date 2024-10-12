# Only static libraries are supported.
# See https://github.com/nanodbc/nanodbc/issues/13
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nanodbc/nanodbc
    REF "v${VERSION}"
    SHA512 4ac6b4034548369e452bb73589be0245493edc139e6e305e35428be5eacbbaa64483797825c075ea0079ddbbdf1acb735dbb7c0168a385450e28fcd46a41f6fd
    HEAD_REF master
    PATCHES
        rename-version.patch
        add-missing-include.patch
        find-unixodbc.patch
        no-werror.patch
)
file(RENAME "${SOURCE_PATH}/VERSION" "${SOURCE_PATH}/VERSION.txt")

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
