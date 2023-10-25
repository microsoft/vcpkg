vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-sdk-for-cpp
    REF azure-storage-files-datalake_12.8.0
    SHA512 4539b8ba806abdf71cdf82e2bdcffe1adae1d19e6ea62f72cea6ac7e0beef32895d13cff53df4afe06b53ed5740c19bba858c09f75b74cd446d5c125e36ca2b3
)

if(EXISTS "${SOURCE_PATH}/sdk/storage/azure-storage-files-datalake")
  file(REMOVE_RECURSE "${SOURCE_PATH}/sdk/storage/_")
  file(REMOVE_RECURSE "${SOURCE_PATH}/sdk/_")
  file(REMOVE_RECURSE "${SOURCE_PATH}/_")

  file(RENAME "${SOURCE_PATH}/sdk/storage/azure-storage-files-datalake" "${SOURCE_PATH}/sdk/storage/_")
  file(RENAME "${SOURCE_PATH}/sdk/storage" "${SOURCE_PATH}/sdk/_")
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
