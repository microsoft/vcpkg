set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
)

vcpkg_cmake_install()

if(NOT VCPKG_CROSSCOMPILING)
    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/bin/${PORT}/")
    vcpkg_execute_required_process(
        COMMAND "${CURRENT_PACKAGES_DIR}/bin/${PORT}/main"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        LOGNAME runtime-${TARGET_TRIPLET}
    )
endif()
