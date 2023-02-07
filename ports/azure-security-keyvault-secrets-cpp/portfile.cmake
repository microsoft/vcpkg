vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-sdk-for-cpp
    REF azure-security-keyvault-secrets_4.1.0
    SHA512 82deeda461aaac3d38adcf1080ecd0b8883dfb6c5e9db6b86deaac2e6d683dac3e97998afeb9a1657da715f9e46f25f9b9a6c4938ade0a1979b1136291d66e7f
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}/sdk/keyvault/azure-security-keyvault-secrets/
    OPTIONS
        -DWARNINGS_AS_ERRORS=OFF
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_cmake_config_fixup()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_copy_pdbs()
