set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        sdformat    TEST_SDFORMAT
        numpy       TEST_NUMPY
)

set(ADDITIONAL_OPTIONS "")
if("numpy" IN_LIST FEATURES)
    x_vcpkg_get_python_packages(
            PYTHON_VERSION 3
            PACKAGES NumPy
            OUT_PYTHON_VAR PYTHON3
    )
    list(APPEND ADDITIONAL_OPTIONS
        "-DPYTHON_EXECUTABLE=${PYTHON3}"
    )
endif ()

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
    OPTIONS
        ${ADDITIONAL_OPTIONS}
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_build()
