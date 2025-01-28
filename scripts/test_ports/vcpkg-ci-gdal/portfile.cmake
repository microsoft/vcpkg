set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_find_acquire_program(PKGCONFIG)
file(COPY_FILE "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/spatialite.pc" "${CURRENT_BUILDTREES_DIR}/spatialite.pc.log")

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
    OPTIONS
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
)
vcpkg_cmake_build()
