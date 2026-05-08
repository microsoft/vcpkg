vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stdiobus/stdiobus-cpp
    REF "v${VERSION}"
    SHA512 43e98c381ba149faba632825ffe650705a10e756fa6dbd80a316f34a9ac784e7afe46ec1feee6901d7541293bbab77b8055c767b7ea8ec9aa6fc197f5bdd9702
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSTDIOBUS_BUILD_TESTS=OFF
        -DSTDIOBUS_BUILD_EXAMPLES=OFF
        -DSTDIOBUS_BUILD_BENCHMARKS=OFF
        -DSTDIOBUS_BUILD_FUZZ=OFF
        -DSTDIOBUS_INSTALL=ON
        -DSTDIOBUS_WARNINGS_AS_ERRORS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME stdiobus CONFIG_PATH lib/cmake/stdiobus)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
