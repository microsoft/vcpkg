set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_INSTALLED_DIR}/share/skia/example"
    OPTIONS
        "-DFEATURES=${FEATURES}"
)
vcpkg_cmake_build()
