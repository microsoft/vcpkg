set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
set(VCPKG_BUILD_TYPE release) # vcpkg limitation
set(ENV{GI_TYPELIB_PATH} "${CURRENT_INSTALLED_DIR}/share/gir-1.0")

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_check_features(OUT_FEATURE_OPTIONS options
    FEATURES
        run-test    RUN_TEST
)

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
    OPTIONS
        ${options}
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
)
vcpkg_cmake_build()
