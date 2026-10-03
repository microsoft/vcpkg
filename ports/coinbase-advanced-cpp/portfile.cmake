vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/coinbase-advanced-cpp
    REF "v${VERSION}"
    SHA512 9a2de3e90944028d38cdfad9e1290a875b11942261b94b9eebd76f95606303ff33bcd946d3b7c45b786af8c87b9b34b5c217cef6f1f3ec7ff80ba97a1cbf9b88
    HEAD_REF main
    PATCHES
        disable-config-fetchcontent-fallback.patch # also https://github.com/SlickQuant/coinbase-advanced-cpp/pull/1
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_COINBASE_ADVANCED_TESTS=OFF
        -DBUILD_COINBASE_ADVANCED_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME coinbase-advanced-cpp CONFIG_PATH lib/cmake/coinbase-advanced-cpp)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
