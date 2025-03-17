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

function(make_rpath_absolute lib_dir)
string(REPLACE "/" "_" logname "make_rpath_absolute-${lib_dir}")
    vcpkg_execute_required_process(
        COMMAND "install_name_tool" -id ${CURRENT_INSTALLED_DIR}/${lib_dir}/librpath-macho-backend-lib++.dylib ${CURRENT_PACKAGES_DIR}/${lib_dir}/librpath-macho-backend-lib++.dylib
        WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}"
        LOGNAME "${logname}-id"
    )
    
    vcpkg_execute_required_process(
        COMMAND "install_name_tool" -change @rpath/librpath-macho-backend-lib++.dylib ${CURRENT_INSTALLED_DIR}/${lib_dir}/librpath-macho-backend-lib++.dylib ${CURRENT_PACKAGES_DIR}/${lib_dir}/librpath-macho-test-lib.dylib
        WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}"
        LOGNAME "${logname}-change"
    )
endfunction()

if(NOT VCPKG_BUILD_TYPE)
    vcpkg_copy_tools(TOOL_NAMES rpath-macho-test-tool
        SEARCH_DIR "${CURRENT_PACKAGES_DIR}/debug/bin"
        DESTINATION "${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}"
    )
    vcpkg_copy_tools(TOOL_NAMES rpath-macho-test-tool
        SEARCH_DIR "${CURRENT_PACKAGES_DIR}/debug/bin"
        DESTINATION "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}/debug"
    )
    vcpkg_copy_tools(TOOL_NAMES rpath-macho-test-tool
        SEARCH_DIR "${CURRENT_PACKAGES_DIR}/debug/bin"
        DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug"
    )
    make_rpath_absolute("debug/lib")
endif()
make_rpath_absolute("lib")
vcpkg_copy_tools(TOOL_NAMES rpath-macho-test-tool DESTINATION "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}")
vcpkg_copy_tools(TOOL_NAMES rpath-macho-test-tool AUTO_CLEAN)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "This test port is part of vcpkg.")
