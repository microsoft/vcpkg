set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
    OPTIONS
        "-Dslang_DIR=${CURRENT_HOST_INSTALLED_DIR}/share/slang"
)
vcpkg_cmake_build()
