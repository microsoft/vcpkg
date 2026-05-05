vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Immediate-Mode-UI/Nuklear
    REF "${VERSION}"
    SHA512 d35fb45ad8e940773f402cc6e5a5cb7bd70b61125a5ab057db554d02eeba4c80cdc205fd1a63f3143a9a0c0db55376feb05ada32253e6de6e9559b7f0f6bce34
    HEAD_REF master
)

file(COPY "${CURRENT_PORT_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        example INSTALL_EXAMPLE
        demo    INSTALL_DEMO
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-nuklear)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/src/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
