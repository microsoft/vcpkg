vcpkg_fail_port_install(ON_TARGET "UWP" ON_ARCH "arm" "arm64")
#vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sciplot/sciplot
    REF v0.1.0
    SHA512 846657530639ec66af052dd26b09170fc2b87590cfc017ac633795af301ac60d46682d55b59f7a88e50669fa3644df625c3001486001a648b0fc913b0c602d89
    HEAD_REF vcpkg
)

vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/sciplot)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
