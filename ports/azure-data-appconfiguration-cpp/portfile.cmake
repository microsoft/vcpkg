# NOTE: All changes made to this file will get overwritten by the next port release.
# Please contribute your changes to https://github.com/Azure/azure-sdk-for-cpp.

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-sdk-for-cpp
    REF e19518ea0aac72eeb8cf74d17eeaab16f3e10e73
    SHA512 6104fe9dc74e2b859c3cc2437d7c8582f29597f796fbfccaefbabcdfda962e3cd588193ae0b4e65b7ad28aaee58b9d29ef8b57223c864ca47d403aaacaaca501
    HEAD_REF main
)

if(EXISTS "${SOURCE_PATH}/sdk/appconfiguration/azure-data-appconfiguration")
  file(REMOVE_RECURSE "${SOURCE_PATH}/sdk/appconfiguration/_")
  file(REMOVE_RECURSE "${SOURCE_PATH}/sdk/_")
  file(REMOVE_RECURSE "${SOURCE_PATH}/_")

  file(RENAME "${SOURCE_PATH}/sdk/appconfiguration/azure-data-appconfiguration" "${SOURCE_PATH}/sdk/appconfiguration/_")
  file(RENAME "${SOURCE_PATH}/sdk/appconfiguration" "${SOURCE_PATH}/sdk/_")
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
