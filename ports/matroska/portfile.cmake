vcpkg_download_distfile(LIBMATROSKA_BACKPORT_251_PATCH
    URLS https://github.com/Matroska-Org/libmatroska/commit/9d2029cde9ad3218742be371f8563c1e79ad8096.patch?full_index=1
    FILENAME libmatroska_backport_251.patch
    SHA512 5be12bad95ba8ad6c3e75adb49742b994e7bde53e30f6dfe12eddbe702ff924762d3e1f03683223ed890be35b15a57913d685cf16c3a59b384ba00f380b26c9c
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Matroska-Org/libmatroska
    REF "release-${VERSION}"
    SHA512 3aa700786581ea9966e8354fa7177c8fc8a5d742ad753058217d0232e7933ba5812e71302aee7ccd8e86061444bc4cccd3bc972d644883ad2715c3f141fcc573
    HEAD_REF master
    PATCHES
        "${LIBMATROSKA_BACKPORT_251_PATCH}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Matroska)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE.LGPL"
)
