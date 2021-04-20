vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-sdk-for-cpp
    REF azure-security-keyvault-common_4.0.0-beta.1
    SHA512 7364bf775bbf6115bf54ee0c2df8b2bae35ea31c669fcbc358edd00a948f2c73926fbf88282ff5442f40ead9cdfc78661a08e4f86002ac2eac5e78ddd13eb33d
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/sdk/keyvault/azure-security-keyvault-common/
    PREFER_NINJA
    OPTIONS
        -DWARNINGS_AS_ERRORS=OFF
)

vcpkg_install_cmake()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_fixup_cmake_targets()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_copy_pdbs()
