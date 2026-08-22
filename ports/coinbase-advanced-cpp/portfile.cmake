vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/coinbase-advanced-cpp
    REF "v${VERSION}"
    SHA512 6d7425668a1f7c0517bd766f61fb9e4e2223ec5b2946934d2667ddd07c25b5d788b22bbbbabd761dd06394b9de491c5cc05effd5c77595423d5063ae244f1d38
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
