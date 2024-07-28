vcpkg_download_distfile(PATCH_FIX_MISSING_HEADERS_IN_AUDISP_FILTER
    URLS https://github.com/linux-audit/audit-userspace/commit/f8e9bc5914d715cdacb2edc938ab339d5094d017.patch?full_index=1
    SHA512 b9606c711befe99ce9540b9885e943733ab06faa55d32bf029b23e1984adf2e914d46bd95b81a2517380c6b9e714b3b3d2181b86586c97dc09a0418ae40bd33f
    FILENAME 0000-fix-missing-header-in-audisp-filter.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO linux-audit/audit-userspace
    SHA512 297664a55ab44b40c9280202c19612cfbfdacc209c4d226461ea5faa638e35617cb516e53d1f0bc3748cdd038d9524f3e5ebe11c8de4a5511ab4f12b7d06478c
    REF "v${VERSION}"
    HEAD_REF master
    PATCHES
        "${PATCH_FIX_MISSING_HEADERS_IN_AUDISP_FILTER}"
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
