set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
    OPTIONS
        "-DWITH_CURL=${VCPKG_TARGET_IS_LINUX}"
)
vcpkg_cmake_build()
