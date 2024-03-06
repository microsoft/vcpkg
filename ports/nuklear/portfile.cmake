vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Immediate-Mode-UI/Nuklear
    REF 0a77211844458673446aa99b8a0ae1090a04e413 # 2022-05-12
    SHA512 57ad5578c534d19ce6dd5e9b8c7b725da6e7f379a5289daed6b7128a1671dc5c368175d1e780a7fcb3405fad989e3bc50a8a921d62301e64e58014e351845cae
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
