vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://repo.or.cz/libtar.git
    REF 6d0ab4c78e7a8305c36a0c3d63fd25cd1493de65 # latest on master
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_install_make()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"  "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYRIGHT")
