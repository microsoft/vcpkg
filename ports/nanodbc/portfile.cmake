# Only static libraries are supported.
# See https://github.com/nanodbc/nanodbc/issues/13
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nanodbc/nanodbc
    REF "v${VERSION}"
    SHA512 c3728c30c79baaf39553b0ddc46b645ecc598baab3ea40b9544465e8d1d81aaeae27415e8be4637154ea0020f8254b76cea8394e123f51f339ef9b35f1c4e2d3
    HEAD_REF main
	PATCHES
		use-vcpkg-unixodbc.patch
)

vcpkg_list(SET options)

if(DEFINED NANODBC_ODBC_VERSION)
    list(APPEND options -DNANODBC_ODBC_VERSION=${NANODBC_ODBC_VERSION})
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNANODBC_BUILD_EXAMPLES=OFF
        -DNANODBC_BUILD_TESTS=OFF
        -DNANODBC_ENABLE_UNICODE=OFF
        ${options}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(READ "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config.cmake" PORT_CONFIG)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config.cmake" "
include(CMakeFindDependencyMacro)
if(WIN32)
    find_dependency(ODBC)
else()
    find_dependency(unofficial-unixodbc CONFIG)
endif()
${PORT_CONFIG}
")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
