# NOTE: All changes made to this file will get overwritten by the next port release.
# Please contribute your changes to https://github.com/Azure/azure-sdk-for-cpp.

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-sdk-for-cpp
    REF e31710264715cd611f04ae695e36067823dd64f1
    SHA512 39220701ace85c5ec696b834cc6ffb3dcac509846b61069e6f1d441d470bc92532b0dacae26ca83c9f0a05732a2091207bdd137bd4cf04cccf181e6cc69c7df7
    HEAD_REF main
)

if(EXISTS "${SOURCE_PATH}/sdk/tables/azure-data-tables")
  file(REMOVE_RECURSE "${SOURCE_PATH}/sdk/tables/_")
  file(REMOVE_RECURSE "${SOURCE_PATH}/sdk/_")
  file(REMOVE_RECURSE "${SOURCE_PATH}/_")

  file(RENAME "${SOURCE_PATH}/sdk/tables/azure-data-tables" "${SOURCE_PATH}/sdk/tables/_")
  file(RENAME "${SOURCE_PATH}/sdk/tables" "${SOURCE_PATH}/sdk/_")
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
