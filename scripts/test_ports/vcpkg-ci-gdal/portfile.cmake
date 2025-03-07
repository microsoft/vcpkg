set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

file(COPY_FILE "${CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig/gdal.pc" "${CURRENT_BUILDTREES_DIR}/gdal.pc.log")

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
    OPTIONS
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
)
vcpkg_cmake_build()
