vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-sdk-for-cpp
    REF azure-template_1.1.0-beta.3144289
    SHA512 6008c072d6feca60ad8d2cf13de0db424c7a639853ee5e1548e3bb8c42a6a49a27e1db2cbe4575ecf86562b3a1258073e96b5423676d27581654f808452817b2
)

if(EXISTS "${SOURCE_PATH}/sdk/template/azure-template")
  file(REMOVE_RECURSE "${SOURCE_PATH}/sdk/template/_")
  file(REMOVE_RECURSE "${SOURCE_PATH}/sdk/_")
  file(REMOVE_RECURSE "${SOURCE_PATH}/_")

  file(RENAME "${SOURCE_PATH}/sdk/template/azure-template" "${SOURCE_PATH}/sdk/template/_")
  file(RENAME "${SOURCE_PATH}/sdk/template" "${SOURCE_PATH}/sdk/_")
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
