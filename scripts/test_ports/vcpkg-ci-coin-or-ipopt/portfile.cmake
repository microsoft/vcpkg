set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO coin-or/Ipopt
    REF ec43e37a06054246764fb116e50e3e30c9ada089
    SHA512 f5b30e81b4a1a178e9a0e2b51b4832f07441b2c3e9a2aa61a6f07807f94185998e985fcf3c34d96fbfde78f07b69f2e0a0675e1e478a4e668da6da60521e0fd6
    HEAD_REF master
)

vcpkg_find_acquire_program(PKGCONFIG)
set(ENV{PKG_CONFIG} "${PKGCONFIG}")

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
    OPTIONS
        "-DIPOPT_PATH=${SOURCE_PATH}"
)
vcpkg_cmake_install()

# Ipopt links but cannot solve anything unless it was built with a sparse
# linear solver, so run the example rather than only building it. cpp_example
# returns its ApplicationReturnStatus, and Solve_Succeeded is 0.
if(NOT VCPKG_CROSSCOMPILING)
    if(CMAKE_HOST_WIN32)
        vcpkg_host_path_list(PREPEND ENV{PATH} "${CURRENT_INSTALLED_DIR}/bin")
    elseif(CMAKE_HOST_APPLE)
        vcpkg_host_path_list(PREPEND ENV{DYLD_LIBRARY_PATH} "${CURRENT_INSTALLED_DIR}/lib")
    else()
        vcpkg_host_path_list(PREPEND ENV{LD_LIBRARY_PATH} "${CURRENT_INSTALLED_DIR}/lib")
    endif()
    vcpkg_execute_required_process(
        COMMAND "${CURRENT_PACKAGES_DIR}/bin/${PORT}/simple-pkgconfig"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        LOGNAME runtime-${TARGET_TRIPLET}
    )
endif()
