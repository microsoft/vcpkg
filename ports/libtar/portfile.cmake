vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://repo.or.cz/libtar.git
    REF 50dcdd27a33444b974d940ed5f225a2444e5aeba
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_install_make()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"  "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/COPYRIGHT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
