vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Immediate-Mode-UI/Nuklear
    REF 6e80e2a646f35be4afc157a932f2936392ec8f74 # accessed on 2021-04-04
    SHA512 ce064dff721111749d4056717879f42d3e24bb94655dd2b04c137eb7391d2c90d0b1b95155912c100b537f74fd150aedc48e0ac85eb72963c66e35ac81048323
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

file(INSTALL "${SOURCE_PATH}/Readme.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
