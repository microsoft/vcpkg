vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-sdk-for-cpp
    REF azure-security-keyvault-administration_4.0.0-beta.3
    SHA512 1209811b470821f929ffd5d09df58ff19b19f13a657acf304fefd457ee533acb3e91774ca6d72d0106e42d601d0bd4d23fbd563f62a4c9a62d686afe61cb4e6c
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/sdk/keyvault/azure-security-keyvault-administration/"
    OPTIONS
        -DWARNINGS_AS_ERRORS=OFF
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_cmake_config_fixup()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_copy_pdbs()
