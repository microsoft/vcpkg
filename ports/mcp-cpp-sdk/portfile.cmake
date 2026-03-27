vcpkg_minimum_required(VERSION 2022-10-12)

vcpkg_buildpath_length_warning(36)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO itcv-GmbH/cpp-mcp-sdk
    REF "v${VERSION}"
    SHA512 395afdf36458d3f099370cd7740738b5fd228bcb25d6ae4a2961a8e9c903ef5729216ac5e5a768732966ff545a3d7a6ceb0a54de4cc65c63939033e49196e859
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMCP_SDK_BUILD_TESTS=OFF
        -DMCP_SDK_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/mcp_sdk")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/mcp/sdk/version.hpp" "MCP_SDK_STATIC_LIB" "MCP_SHARED_LIB")
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
