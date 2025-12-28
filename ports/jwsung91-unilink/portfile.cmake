vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jwsung91/unilink
    REF v0.2.1
    SHA512 80a8f0e6cbb56b30f1ae02eaa25d33e708c20ce81f815f372bfd7a956600f9329461f75b161c576654685ca2e8f8744a9194103748b1a7f9033f531067e3730e)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" UNILINK_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUNILINK_BUILD_SHARED=${UNILINK_BUILD_SHARED}
        -DUNILINK_BUILD_TESTS=OFF
        -DUNILINK_BUILD_EXAMPLES=OFF
        -DUNILINK_BUILD_DOCS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME unilink
    CONFIG_PATH "lib/cmake/unilink"
)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
