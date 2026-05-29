set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
    OPTIONS
        "-DFEATURES=${FEATURES}"
)
vcpkg_cmake_install()

if("run-programs" IN_LIST FEATURES)
    # lua executable"
    message(STATUS "Running lua")
    vcpkg_execute_required_process(
        COMMAND "${CURRENT_INSTALLED_DIR}/tools/lua/lua" -e "print(package.path)"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        LOGNAME execute-lua-${TARGET_TRIPLET}
    )
    # user executable (this port)
    if(CMAKE_HOST_WIN32)
        vcpkg_host_path_list(PREPEND ENV{PATH} "${CURRENT_INSTALLED_DIR}/bin")
    elseif(CMAKE_HOST_APPLE)
         vcpkg_host_path_list(PREPEND ENV{DYLD_LIBRARY_PATH} "${CURRENT_INSTALLED_DIR}/lib")
    else()
         vcpkg_host_path_list(PREPEND ENV{LD_LIBRARY_PATH} "${CURRENT_INSTALLED_DIR}/lib")
    endif()
    message(STATUS "Running main")
    vcpkg_execute_required_process(
        COMMAND "${CURRENT_PACKAGES_DIR}/bin/${PORT}/main"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        LOGNAME execute-main-${TARGET_TRIPLET}
    )
endif()
