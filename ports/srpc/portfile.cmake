vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sogou/srpc
    REF v${VERSION}
    SHA512 55c0ebbf30c24fdb40885792d5d3f1e183f27fcf13df6217053bec13cf9ed6359888351b20a792607b1f49df674b88bd148cf4c8addb1f610b1c59dd4eeba0f2
    HEAD_REF master
    PATCHES
        protobuf.patch
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" SRPC_BUILD_STATIC_RUNTIME)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DSRPC_BUILD_STATIC_RUNTIME=${SRPC_BUILD_STATIC_RUNTIME}
        -DCMAKE_CXX_STANDARD=11
    MAYBE_UNUSED_VARIABLES
        SRPC_BUILD_STATIC_RUNTIME
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/srpc)
vcpkg_copy_pdbs()
vcpkg_copy_tools(
    TOOL_NAMES srpc_generator
    AUTO_CLEAN
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
