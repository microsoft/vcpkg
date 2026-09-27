set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
)
vcpkg_cmake_install()

# Run the sample only on the native CI triplets we explicitly want runtime
# coverage for. Other supported triplets stay build-only for now.
if(NOT VCPKG_CROSSCOMPILING AND
   (TARGET_TRIPLET STREQUAL "arm64-osx" OR
    TARGET_TRIPLET STREQUAL "x64-linux" OR
    TARGET_TRIPLET STREQUAL "x64-windows"))
    if(CMAKE_HOST_WIN32)
        vcpkg_host_path_list(PREPEND ENV{PATH} "${CURRENT_INSTALLED_DIR}/bin")
    elseif(CMAKE_HOST_APPLE)
        vcpkg_host_path_list(PREPEND ENV{DYLD_LIBRARY_PATH} "${CURRENT_INSTALLED_DIR}/lib")
    else()
        vcpkg_host_path_list(PREPEND ENV{LD_LIBRARY_PATH} "${CURRENT_INSTALLED_DIR}/lib")
    endif()

    vcpkg_execute_required_process(
        COMMAND "${CURRENT_PACKAGES_DIR}/bin/${PORT}/main"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        LOGNAME runtime-${TARGET_TRIPLET}
    )
endif()
