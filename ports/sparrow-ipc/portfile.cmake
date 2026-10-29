if(VCPKG_TARGET_IS_LINUX)
    message("Warning: `sparrow-ipc` requires Clang18+ or GCC 11.2+ on Linux")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sparrow-org/sparrow-ipc
    REF "${VERSION}"
    SHA512 c79d0f076fc3b64755aa705c56137363b6a91194bd44072a6d732ebbfd161653b5f57538eedc1f496af25202f23e85ff60f77f1b727cbcce8663c4b7f15a280d
    HEAD_REF main
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SPARROW_IPC_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DSPARROW_IPC_BUILD_SHARED=${SPARROW_BUILD_SHARED}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/sparrow-ipc)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
