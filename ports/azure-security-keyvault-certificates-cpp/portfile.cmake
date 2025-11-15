# NOTE: All changes made to this file will get overwritten by the next port release.
# Please contribute your changes to https://github.com/Azure/azure-sdk-for-cpp.

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-sdk-for-cpp
    REF 62663382da72507b557071f7157e421bc887cb32
    SHA512 9d0da652290dca3fcaf08ee01a18eef58eb2cc3e03c9f90f64b882e3df57fddd5c4ff0b8c6f4b103f335382a6bad81cea3edfdba54ea39f81dd211e3884fd38c
    HEAD_REF main
)

file(GLOB_RECURSE unused "${SOURCE_PATH}/cgmanifest.json")
file(REMOVE_RECURSE ${unused})

if(EXISTS "${SOURCE_PATH}/sdk/keyvault/azure-security-keyvault-certificates")
  file(REMOVE_RECURSE "${SOURCE_PATH}/sdk/keyvault/_")
  file(REMOVE_RECURSE "${SOURCE_PATH}/sdk/_")
  file(REMOVE_RECURSE "${SOURCE_PATH}/_")

  file(RENAME "${SOURCE_PATH}/sdk/keyvault/azure-security-keyvault-certificates" "${SOURCE_PATH}/sdk/keyvault/_")
  file(RENAME "${SOURCE_PATH}/sdk/keyvault" "${SOURCE_PATH}/sdk/_")
  file(RENAME "${SOURCE_PATH}/sdk" "${SOURCE_PATH}/_")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/_/_/_"
    OPTIONS
        -DWARNINGS_AS_ERRORS=OFF
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_cmake_config_fixup()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_copy_pdbs()
