vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://github.com/kubernetes-client/c.git
    REF f6465c8fb099f2c8fcf1f84edd5e880610600f10
    PATCHES
        001-fix-destination.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/kubernetes
    PREFER_NINJA)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL ${CURRENT_PORT_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
