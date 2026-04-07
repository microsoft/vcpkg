set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(host_python "${CURRENT_HOST_INSTALLED_DIR}/tools/python3/python3${VCPKG_HOST_EXECUTABLE_SUFFIX}")
if(VCPKG_HOST_IS_WINDOWS)
    set(host_python "${CURRENT_HOST_INSTALLED_DIR}/tools/python3/python.exe")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
    OPTIONS
        "-DPython_EXECUTABLE=${host_python}"
        "-DPython3_EXECUTABLE=${host_python}"
    OPTIONS_DEBUG
        "-DEXPECTED_LIBRARY_KEYWORD=debug"
        "-DEXPECTED_LIBRARY_PREFIX=${CURRENT_INSTALLED_DIR}/debug/lib"
    OPTIONS_RELEASE
        "-DEXPECTED_LIBRARY_KEYWORD=optimized"
        "-DEXPECTED_LIBRARY_PREFIX=${CURRENT_INSTALLED_DIR}/lib"
)
vcpkg_cmake_build()
