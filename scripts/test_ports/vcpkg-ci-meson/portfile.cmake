set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_configure_meson(SOURCE_PATH "${CURRENT_PORT_DIR}/project")
vcpkg_install_meson()
