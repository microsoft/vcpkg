vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO symisc/unqlite
    REF ddb1687036d207bbfc67b98cb470fe52ddf22f62 # 1.1.9
    SHA512 eaabaf5f35662a6ea734c18878f55f5e6e956cd151bb941321f97247bbe0b7f402ceca39c191d31e87db1c04188ca0eaf69c9b202848babfe23d5ffee48df9a7
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
