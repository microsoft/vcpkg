vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Immediate-Mode-UI/Nuklear
    REF "${VERSION}"
    SHA512 fc3613fc579825d22c103225bcca72d1e9fbb349fe06237e4d77652d7af3293e33e983be03dd4180c93c4c7602a2529c5c1edd87cde3d5efe09ec787818bac48
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
