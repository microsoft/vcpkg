vcpkg_cmake_configure(
    SOURCE_PATH "${CMAKE_CURRENT_LIST_DIR}"
)

vcpkg_cmake_install()

if(NOT VCPKG_BUILD_TYPE)
    vcpkg_copy_tools(
        TOOL_NAMES consumer
        SEARCH_DIR "${CURRENT_PACKAGES_DIR}/debug/bin"
        DESTINATION "${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}"
    )
    execute_process(
        COMMAND "${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}/consumer${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
        COMMAND_ERROR_IS_FATAL ANY
    )
endif()

vcpkg_copy_tools(
    TOOL_NAMES consumer
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}"
)
execute_process(
    COMMAND "${CURRENT_PACKAGES_DIR}/tools/${PORT}/consumer${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
    COMMAND_ERROR_IS_FATAL ANY
)

vcpkg_clean_executables_in_bin(FILE_NAMES consumer)

vcpkg_install_copyright(FILE_LIST "${CMAKE_CURRENT_LIST_DIR}/License")

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
