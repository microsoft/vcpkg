set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
    OPTIONS
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
        "-DVCPKG_CHECK_CMAKE_BUILD_TYPE=${VCPKG_BUILD_TYPE}"
        "-DVCPKG_CROSSCOMPILING=${VCPKG_CROSSCOMPILING}"
)
vcpkg_cmake_build()
