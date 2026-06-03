vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jwsung91/unilink
    REF v${VERSION}
    SHA512 8b9ca2f47c18ab34fe96eb877ed0c83bb7e6a5503a33207d7cbbe217f4eae6c09cf17885f882cdc459d9b4f3d860351c52a6485ade30c8cdcf5f96c3dee325d5
)

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
