set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
    OPTIONS_RELEASE
        -DTEST_STRING=release
    OPTIONS_DEBUG
        -DTEST_STRING=debug
)
vcpkg_cmake_install()

if(NOT VCPKG_BUILD_TYPE)
    vcpkg_copy_tools(TOOL_NAMES rpath-test-tool
        SEARCH_DIR "${CURRENT_PACKAGES_DIR}/debug/bin"
        DESTINATION "${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}"
    )
    vcpkg_copy_tools(TOOL_NAMES rpath-test-tool
        SEARCH_DIR "${CURRENT_PACKAGES_DIR}/debug/bin"
        DESTINATION "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}/debug"
    )
    vcpkg_copy_tools(TOOL_NAMES rpath-test-tool
        SEARCH_DIR "${CURRENT_PACKAGES_DIR}/debug/bin"
        DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug"
    )
endif()
vcpkg_copy_tools(TOOL_NAMES rpath-test-tool DESTINATION "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}")
vcpkg_copy_tools(TOOL_NAMES rpath-test-tool AUTO_CLEAN)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "This test port is part of vcpkg.")
