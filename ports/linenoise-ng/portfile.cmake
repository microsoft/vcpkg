vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arangodb/linenoise-ng
    REF 4754bee2d8eb3c4511e6ac87cac62255b2011e2f
    SHA512 080c6b4cde911a162885a2e6fc95143ab481b4dcc0f8b871a55a071ccb4ab868b19201ec17475a3c3ceef1b82325d757913383b3c46da6946ddc8bfc0d82d9ca
    HEAD_REF master
)


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/linenoise-ng RENAME copyright)
