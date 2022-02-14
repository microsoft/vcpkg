vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO emil-e/rapidcheck
    REF 08b505857e32d52a20b2240b5125d937d67a6d86
    SHA512 d71d17354d2597a168be935e03b1330fc96ff12d6551b6bd34ef8f6c2ba69f7f9bff865afd6a6a59c48496bcc9ddf997b07112d80c761d909f7cd9ef93a7464b
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DRC_INSTALL_ALL_EXTRAS=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/${PORT}/cmake)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

configure_file(${SOURCE_PATH}/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
