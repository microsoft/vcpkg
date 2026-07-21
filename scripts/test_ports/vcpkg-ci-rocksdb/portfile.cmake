set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(OPTIONS)
if (VCPKG_TARGET_IS_LINUX)
    vcpkg_find_acquire_program(PKGCONFIG)
    vcpkg_list(APPEND OPTIONS "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
    OPTIONS ${OPTIONS}
)

vcpkg_cmake_build()
