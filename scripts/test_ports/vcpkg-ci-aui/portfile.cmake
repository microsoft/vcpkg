set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

if(NOT VCPKG_TARGET_IS_WINDOWS)
    vcpkg_find_acquire_program(PKGCONFIG)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
    OPTIONS
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
)
vcpkg_cmake_build()
