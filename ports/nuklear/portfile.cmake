vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Immediate-Mode-UI/Nuklear
    REF "v${VERSION}"
    SHA512 8cfc050afb975f414ea694ac395e14cb2274da5647a48a1a164894532373c5d19d87f2cac5b38fbab72ad87e89c5b8f028c2097e17c0fb97c70f954593de1d68
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
