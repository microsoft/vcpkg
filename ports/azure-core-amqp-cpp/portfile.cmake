vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-sdk-for-cpp
    REF azure-core-amqp_1.0.0-beta.1
    SHA512 4fc520c546cd395d4c50a9385d33db09b50865046b5383b1442057d4ac78ffc6a6be221af6aef3dcb938ffde1927e8de4270d5b1c9cf5d97ac8b1581b51d014b
    PATCHES
        00100-fix_dependency.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/sdk/core/azure-core-amqp/"
    OPTIONS
        -DWARNINGS_AS_ERRORS=OFF
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_cmake_config_fixup()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_copy_pdbs()
