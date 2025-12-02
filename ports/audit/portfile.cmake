vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO linux-audit/audit-userspace
    SHA512 a47fec1041e11a76ad57b57bcf6e9b454188d95ec26cabf15e92e114d46c7c8f09ddb251d5aebef8bc7faacc6ccffe44c73543d8234af237548b4ad89a408fc3
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
