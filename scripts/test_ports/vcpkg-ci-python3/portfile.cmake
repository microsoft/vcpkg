set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
    OPTIONS_DEBUG
        "-DEXPECTED_LIBRARY_KEYWORD=debug"
        "-DEXPECTED_LIBRARY_PREFIX=${CURRENT_INSTALLED_DIR}/debug/lib"
    OPTIONS_RELEASE
        "-DEXPECTED_LIBRARY_KEYWORD=optimized"
        "-DEXPECTED_LIBRARY_PREFIX=${CURRENT_INSTALLED_DIR}/lib"
)
vcpkg_cmake_build()
