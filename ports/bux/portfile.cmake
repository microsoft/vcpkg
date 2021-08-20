vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO buck-yeh/bux
    REF 4636183159f74f350238e6ee59583b34f7e7aca9 # v1.4.1
    SHA512 0
    HEAD_REF main
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/bux RENAME copyright)
