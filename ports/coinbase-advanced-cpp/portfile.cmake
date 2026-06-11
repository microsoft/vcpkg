vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/coinbase-advanced-cpp
    REF v0.3.0
    SHA512 984d96a9358839738bb7a1753ce7f1f748a0e6a0d0dbf0f6e6d8ae1c163012de84571f3ecf65ec8e49b120103baca0d7a2091761c84ff3aa7f95837da9cbca10
    HEAD_REF main
    PATCHES
        disable-config-fetchcontent-fallback.patch # also https://github.com/SlickQuant/coinbase-advanced-cpp/pull/1
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_COINBASE_ADVANCED_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME coinbase-advanced-cpp CONFIG_PATH lib/cmake/coinbase-advanced-cpp)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
