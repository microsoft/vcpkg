vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO linux-audit/audit-userspace
    SHA512 4ebdfaebb89440bd76d1f715aa9f2f261b453f51c66ae9c4c7ad650cd361268fe2415c33fe7913ec4986d98ccbd457e15734d0aae606b5dccf316b66276a13cb
    REF "v${VERSION}"
    HEAD_REF master
)

message(STATUS "${PORT} currently requires the following libraries from the system package manager:\n"
    "\t- <autoconf>\n"
    "\t- <automake>\n"
    "\t- <libtool>\n\n"
    "It can be installed with your package manager"
)

file(TOUCH "${SOURCE_PATH}/README")

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        --with-python3=no
        --with-golang=no
        --with-io_uring=no
        --with-warn=no
        --disable-zos-remote
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
