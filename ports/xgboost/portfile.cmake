vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dmlc/xgboost
    REF v${VERSION}
    SHA512 4465f383df70ee415faaeb745459bfc413f71bff0d02e59e67173975188bed911044dbea1a456550496f8c5a7c0b50002275b6be72c87386a6118485e1e41829
    HEAD_REF master
)

# Set the expected path of the dmlc-core directory inside the xgboost source directory
vcpkg_from_github(
    OUT_SOURCE_PATH DMLC_CORE_SRC
    REPO dmlc/dmlc-core
    REF 81db539486ce6525b31b971545edffee2754aced
    SHA512 9b288fd1ceeef0015e80b0296b0d4015238d4cc1b7c36ba840d3eabce87508e62ed5b4fe61504f569dadcc414882903211fadf54aa0e162a896b03d7ca05e975
    HEAD_REF master
)

# Custom CMake script to move dmlc-core to the correct location
file(REMOVE_RECURSE "${SOURCE_PATH}/dmlc-core")
file(RENAME "${DMLC_CORE_SRC}" "${SOURCE_PATH}/dmlc-core")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# Configure and build dmlc-core first
# vcpkg_cmake_configure(
#     SOURCE_PATH "${SOURCE_PATH}/dmlc-core"
# )

# vcpkg_cmake_install()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()

# Adjustments to address the warnings
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(PACKAGE_NAME xgboost CONFIG_PATH "lib/cmake")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

