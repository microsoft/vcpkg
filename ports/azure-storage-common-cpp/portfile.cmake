vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-sdk-for-cpp
    REF azure-storage-common_12.3.2
    SHA512 e437c12ba1056838a1d68257522f412f709b4bcbd3e58d4f7fc47768f125a61258667e0f4fcb93927522da9ab2a9495c3d8c53d81f01a86feb142a7025b1ee4c
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/sdk/storage/azure-storage-common/"
    OPTIONS
        -DWARNINGS_AS_ERRORS=OFF
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_cmake_config_fixup()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_copy_pdbs()
