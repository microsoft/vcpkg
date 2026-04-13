if(VCPKG_TARGET_IS_LINUX)
    message("Warning: `sparrow-ipc` requires Clang18+ or GCC 11.2+ on Linux")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sparrow-org/sparrow-ipc
    REF "${VERSION}"
    SHA512 73c7bb4505bffcf1bdfbb68cd77b0b395c59e463b863c5dd219985b68bc6644d70b54131321c0675b315cd9ef02fcc34534e9c3e5d09f0b8b1b3402c5b1073a4
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
