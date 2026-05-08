vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jwsung91/unilink
    REF v${VERSION}
    SHA512 98835a2cfac3861652b8cf3f53c77b0eb03c9ec0ca2480bfcd95607fed5a2d683686f0e859e5d437cbca4c2ca1fcaacda8873d4dae6ba88c8bc6a1f781f40546
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
