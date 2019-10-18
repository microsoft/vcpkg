vcpkg_fail_port_install(MESSAGE "${PORT} currently only supports Linux platform" ON_TARGET "Windows" "OSX")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO luke-jr/libbase58
    REF 16c2527608053d2cc2fa05b2e3b5ae96065d1410
    SHA512 c5473ab33cff9cd242e980c77fa8fb9da7b33e7e50011f356ea98b692b23a24abf5dcade5fc09528e759cf0ea84a8fce75c28f7f6a9f409cbdeeaf49241a51da
    HEAD_REF mater
)

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
)

vcpkg_install_make()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)