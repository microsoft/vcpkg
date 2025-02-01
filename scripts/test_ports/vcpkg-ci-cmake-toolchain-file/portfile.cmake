set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
    DISABLE_PARALLEL_CONFIGURE  # keep separate logs
)
vcpkg_cmake_build()
