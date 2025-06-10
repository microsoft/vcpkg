vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NVIDIA/ai-assisted-annotation-client
    REF 2706251c9c8444e2a6e7f6fe9943a1a45e2c9da2 # v1.0.2
    SHA512 1e2d8b1ff14f85a92aeea1a294ec3a1e151b0bf1a8c4e596fe6889ac91ba3463a502246982858f0fd8080a0da1bc1beb5efdf5efe4f85cff593e2ae467ed198e
    HEAD_REF master
    PATCHES
        remove-thirdparty-include.patch
)

# The project uses a SuperBuild system by default, but we want to use vcpkg dependencies
# We need to disable the SuperBuild and configure to use system packages
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUSE_SUPERBUILD=OFF
        -DAIAA_LOG_DEBUG_ENABLED=0
        -DAIAA_LOG_INFO_ENABLED=1
    MAYBE_UNUSED_VARIABLES
        USE_SUPERBUILD
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME NvidiaAIAAClient)

# Remove debug files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")