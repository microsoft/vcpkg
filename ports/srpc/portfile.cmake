if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sogou/srpc
    REF "v${VERSION}"
    SHA512 5452a8b1e23a5d1dfc7773e71980e0e3367da165f7637217f788d6ecbceff11f63679376d36a26b3161c8c9683c5e3b16dfd21c9be3a4f9214271a92a8e260f8
    HEAD_REF master
    PATCHES
        cmake.diff
)
file(REMOVE_RECURSE "${SOURCE_PATH}/third_party")
file(REMOVE_RECURSE "${SOURCE_PATH}/workflow")

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" SRPC_BUILD_STATIC_RUNTIME)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DCMAKE_POLICY_DEFAULT_CMP0175=OLD
        -DSRPC_BUILD_STATIC_RUNTIME=${SRPC_BUILD_STATIC_RUNTIME}
        "-DPROTOC=${CURRENT_HOST_INSTALLED_DIR}/tools/protobuf/protoc${VCPKG_HOST_EXECUTABLE_SUFFIX}"
        -DLZ4_INSTALLED=1
        -DSNAPPY_INSTALLED=1
        -DWORKFLOW_INSTALLED=1
    MAYBE_UNUSED_VARIABLES
        SRPC_BUILD_STATIC_RUNTIME
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/srpc)

vcpkg_copy_tools(
    TOOL_NAMES srpc_generator
    AUTO_CLEAN
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
