vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SamuelMarks/c-str-span
    REF "${VERSION}"
    SHA512 c413700e6acda9f01b9ce43d31b020469107323f49c4af4ab11340c677b91e01c2351c16e8cd9feb56168d9fe492d03483f51bd3a5e8c68237bd904a16ab7c04
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME c_str_span)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE-MIT")
