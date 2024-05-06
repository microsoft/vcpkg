vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qicosmos/cinatra
    REF ${VERSION}
    SHA512 55bba51bb6190b76bc6415d3c36e82daeb5f174f1cb10490951cf05863f55653a6d68ffd3b66c5b3b2ebb6e68a7a84c090e973a6718f3f2a5849b04330e4b180
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/cinatra RENAME copyright)
vcpkg_copy_pdbs()
file(REMOVE_RECURSE ${SOURCE_PATH}/.git)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)






