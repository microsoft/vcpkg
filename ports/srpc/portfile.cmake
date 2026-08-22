if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sogou/srpc
    REF v${VERSION}
    SHA512 ff28eaf0b9cb02d63efb7419a3b10163096e16d0c750bc74da53f5253d45b08f5589b02cdf41177846d49814afd72fd45bc7797c50311f26d4fffc4b0fcecc14
    HEAD_REF master
    PATCHES
        cmake.diff
)
file(REMOVE_RECURSE "${SOURCE_PATH}/third_party")
file(REMOVE_RECURSE "${SOURCE_PATH}/workflow")

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" SRPC_BUILD_STATIC_RUNTIME)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
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
