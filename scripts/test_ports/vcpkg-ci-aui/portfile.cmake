set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_host_path_list(PREPEND ENV{PATH} "${CURRENT_HOST_INSTALLED_DIR}/tools/aui-toolbox")

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
    OPTIONS
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
)
vcpkg_cmake_build()
