vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO linux-audit/audit-userspace
    SHA512 e5493f434dddbded65f33bfd56981036af6975c192289a05378d773ce914ab3ffe6b7071cae03e8f69da4e33246a38608d848f64d01647f2572a7eb6651f3ba0
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

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    OPTIONS
        --with-python3=no
        --with-golang=no
        --with-io_uring=no
        --with-warn=no
        --disable-zos-remote
)

vcpkg_make_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
