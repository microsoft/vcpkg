set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
    OPTIONS
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
    OPTIONS_RELEASE
        "-DGM_CONFIG=${CURRENT_INSTALLED_DIR}/tools/graphicsmagick/bin/GraphicsMagick-config"
    OPTIONS_DEBUG
        "-DGM_CONFIG=${CURRENT_INSTALLED_DIR}/tools/graphicsmagick/debug/bin/GraphicsMagick-config"
)
vcpkg_cmake_build()
