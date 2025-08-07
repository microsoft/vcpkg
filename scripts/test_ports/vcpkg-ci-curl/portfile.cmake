set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
    OPTIONS
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
    OPTIONS_RELEASE
        "-DCURL_CONFIG=${CURRENT_INSTALLED_DIR}/tools/curl/bin/curl-config"
    OPTIONS_DEBUG
        "-DCURL_CONFIG=${CURRENT_INSTALLED_DIR}/tools/curl/debug/bin/curl-config"
)
vcpkg_cmake_build()
