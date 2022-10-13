vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-sdk-for-cpp
    REF azure-storage-blobs_12.6.2
    SHA512 3f92ec18500be9904e577f36549631903e40f43ea33a83fce4a4646d7d0fc426be9611f459a847452db3e31c887c2121b77054926aadcab00fbc614f26a724d9
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}/sdk/storage/azure-storage-blobs/
    OPTIONS
        -DWARNINGS_AS_ERRORS=OFF
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_cmake_config_fixup()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_copy_pdbs()
