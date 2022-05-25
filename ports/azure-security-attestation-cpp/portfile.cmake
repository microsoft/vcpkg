vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-sdk-for-cpp
    REF azure-security-attestation_1.0.0-beta.2
    SHA512 5a7e4ef8740f277e388d6d1d75a40723208c1b806ae8b8f7ba9c476259f6c968c08cbd8604321018acf659871b3411aed6be40a041141057978b6bb102338846
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}/sdk/attestation/azure-security-attestation/
    OPTIONS
        -DWARNINGS_AS_ERRORS=OFF
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_cmake_config_fixup()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_copy_pdbs()
