set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
)
vcpkg_cmake_install()

if(NOT VCPKG_CROSSCOMPILING)
    if(CMAKE_HOST_WIN32)
        vcpkg_host_path_list(PREPEND ENV{PATH} "${CURRENT_INSTALLED_DIR}/bin")
    elseif(CMAKE_HOST_APPLE)
        vcpkg_host_path_list(PREPEND ENV{DYLD_LIBRARY_PATH} "${CURRENT_INSTALLED_DIR}/lib")
    else()
        vcpkg_host_path_list(PREPEND ENV{LD_LIBRARY_PATH} "${CURRENT_INSTALLED_DIR}/lib")
    endif()

    vcpkg_execute_required_process(
        COMMAND "${CURRENT_PACKAGES_DIR}/bin/${PORT}/rdkit-cairo-consumer${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        LOGNAME release-test
    )

    if(NOT VCPKG_BUILD_TYPE)
        if(CMAKE_HOST_WIN32)
            vcpkg_host_path_list(PREPEND ENV{PATH} "${CURRENT_INSTALLED_DIR}/debug/bin")
        elseif(CMAKE_HOST_APPLE)
            vcpkg_host_path_list(PREPEND ENV{DYLD_LIBRARY_PATH} "${CURRENT_INSTALLED_DIR}/debug/lib")
        else()
            vcpkg_host_path_list(PREPEND ENV{LD_LIBRARY_PATH} "${CURRENT_INSTALLED_DIR}/debug/lib")
        endif()

        vcpkg_execute_required_process(
            COMMAND "${CURRENT_PACKAGES_DIR}/debug/bin/${PORT}/rdkit-cairo-consumer${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
            LOGNAME debug-test
        )
    endif()
endif()
