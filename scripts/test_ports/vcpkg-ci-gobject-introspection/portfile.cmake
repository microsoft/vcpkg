set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

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
    OPTIONS_RELEASE
        "-DGI_TYPELIB_PATH=${CURRENT_INSTALLED_DIR}/lib/girepository-1.0"
    OPTIONS_DEBUG
        "-DGI_TYPELIB_PATH=${CURRENT_INSTALLED_DIR}/debug/lib/girepository-1.0"
)
vcpkg_cmake_build(ADD_BIN_TO_PATH)
