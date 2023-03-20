vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-sdk-for-cpp
    REF azure-security-keyvault-administration_4.0.0-beta.2
    SHA512 9f4f9f115bbc922cc62fd6aa75e4eb56aaed21058e0defd129993c38888dc90cdd29b3c4e746f8b1fb0c716cefe5d605e59994a68a7d6aaf7fdbcee0a81c535e
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}/sdk/keyvault/azure-security-keyvault-administration/
    OPTIONS
        -DWARNINGS_AS_ERRORS=OFF
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_cmake_config_fixup()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_copy_pdbs()
