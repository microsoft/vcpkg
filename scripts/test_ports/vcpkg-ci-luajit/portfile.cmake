set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_find_acquire_program(PKGCONFIG)
set(ENV{PKG_CONFIG} "${PKGCONFIG}")

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
)
vcpkg_cmake_install()

if("run-programs" IN_LIST FEATURES)
    # luajit executable"
    message(STATUS "Running luajit")
    vcpkg_execute_required_process(
        COMMAND "${CURRENT_INSTALLED_DIR}/tools/luajit/luajit" -e "print(package.path)"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        LOGNAME execute-luajit-${TARGET_TRIPLET}
    )
    # luajit executable and "${CURRENT_INSTALLED_DIR}/tools/luajit/jit/v.lua"
    message(STATUS "Running luajit with v.lua")
    vcpkg_execute_required_process(
        COMMAND "${CURRENT_INSTALLED_DIR}/tools/luajit/luajit" -jv -e "for i=1,1000 do for j=1,1000 do end end"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        LOGNAME execute-luajit-v.lua-${TARGET_TRIPLET}
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
