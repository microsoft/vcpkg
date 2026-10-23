vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/coinbase-advanced-cpp
    REF "v${VERSION}"
    SHA512 8094c2e7d443fb71c47b1e2e4d161668d6e699b3e5769771bd15146454c44489d19f2ca77d7cb19878171f0b125f60e1dd2578be97a67ba9e3fda3c9d824b568
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
