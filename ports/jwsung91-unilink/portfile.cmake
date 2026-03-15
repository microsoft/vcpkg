vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jwsung91/unilink
    REF v${VERSION}
    SHA512 e653eddf9a4623fa4cacbbb924a5b2cf5fc01177e246a29833eda70d1ae62b3e784a7c8ac912185c70c767dd238aa4445b050b15c8fc2b4a356e92927453efc0
    PATCHES
        include-cstdint.patch
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
