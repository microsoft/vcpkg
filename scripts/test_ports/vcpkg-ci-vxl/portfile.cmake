set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
    OPTIONS_DEBUG
        -DBUILD_TYPE=debug
)
vcpkg_cmake_build()
