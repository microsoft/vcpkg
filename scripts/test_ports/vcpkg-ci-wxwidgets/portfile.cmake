set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_check_features(OUT_FEATURE_OPTIONS OPTIONS
    FEATURES
        wxrc    USE_WXRC
)

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_INSTALLED_DIR}/share/wxwidgets/example"
    OPTIONS
        ${OPTIONS}
)
vcpkg_cmake_build()
