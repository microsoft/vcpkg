vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO offscale/c89stringutils
    REF "${VERSION}"
    SHA512 5da70176c64c98f8b933e308ee2a6a617b32faaf242b3060a98a012800939608a6deeb429d0ea639b9c2c82b8b3933d42647ba5ab16ece772c4949d9ed3025ed
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE-APACHE" "${SOURCE_PATH}/LICENSE-MIT")
