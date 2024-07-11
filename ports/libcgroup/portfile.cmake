vcpkg_download_distfile(PATCH_FIX_SYSTEMD_HEADER_INSTALLATION
    URLS https://github.com/t43rr7/libcgroup/commit/592dcdcf243576bd2517d3da9bc18990de08e37e.patch?full_index=1
    SHA512 0977e0b32119d1938ce2af6687ff31f6349aa6189307041d1249967e688ed9d84bc133ef270eb3d474a81644dd2152213c8605c6bd9a585c880fef0e026170fa
    FILENAME 0000-fix-systemd-header-installation.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libcgroup/libcgroup
    SHA512 29fb7f5c795080cafc27ab99f2f3d7683933515840226564e047605e41a76f7ca31b48c8c9e8e1963eb808e3fc82206ea6ad550c80dcfb745b5cb7425e2875a9
    REF "v${VERSION}"
    HEAD_REF master
    PATCHES
        "${PATCH_FIX_SYSTEMD_HEADER_INSTALLATION}"
)

message(STATUS "${PORT} currently requires the following libraries from the system package manager:\n"
    "\t- <autoconf>\n"
    "\t- <automake>\n"
    "\t- <libtool>\n\n"
    "It can be installed with your package manager"
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        --enable-tools=no
        --enable-python=no
        --enable-tests=no
        --enable-samples=no
        --enable-systemd=no
        --enable-pam=no
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
