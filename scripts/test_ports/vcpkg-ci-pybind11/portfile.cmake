set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_get_vcpkg_installed_python(PYTHON3)

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
    OPTIONS
        "-DPython_EXECUTABLE=${PYTHON3}"
)
vcpkg_cmake_build()
