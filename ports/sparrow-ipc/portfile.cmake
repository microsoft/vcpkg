if(VCPKG_TARGET_IS_LINUX)
    message("Warning: `sparrow-ipc` requires Clang18+ or GCC 11.2+ on Linux")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sparrow-org/sparrow-ipc
    REF "${VERSION}"
    SHA512 1a96f489ef923748c27413e07590805782f2cd46c9a625638aed601ad35c96acece058e3849a2a727ccbec294dc388dad4c8e27e54a750ab8df69c08802a1882
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
