vcpkg_fail_port_install(MESSAGE "${PORT} currently only supports unix platform" ON_TARGET "Windows")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gpg/libgpg-error
    REF libgpg-error-1.39
    SHA512 c8ca3fc9f1bec90a84214c8fed6073f5a0f6f6880c166a8737a24e0eee841ed5f0f3c94028b50b76535cb2e06f0362b19638e429b4cdc399487d6001b977bbbe
    HEAD_REF master
    PATCHES
        add_cflags_to_tools.patch
)

vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        --disable-tests
        --disable-doc
        --disable-silent-rules
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig() 
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(INSTALL ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
