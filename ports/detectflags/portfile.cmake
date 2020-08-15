
set(VCPKG_BUILD_TYPE release)
vcpkg_configure_cmake(
    SOURCE_PATH ${CURRENT_PORT_DIR}
    PREFER_NINJA
)

