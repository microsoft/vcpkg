vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/krpc/krpc/releases/download/v${VERSION}/krpc-cnano-${VERSION}.zip"
    FILENAME "krpc-cnano-${VERSION}.zip"
    SHA512 2d6caa4d7459e40d910117edf23bd90d1ccd12caa8d8c30a48c68c9eb38ad02e0b4811626f724aba9f2c1cb2bf4e43d2a3859864329ec0bbc08e4920afc22acb
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    SOURCE_BASE "krpc-cnano-${VERSION}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DKRPC_FETCH_NANOPB=OFF
        -DKRPC_REGENERATE_PROTO=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/krpc_cnano PACKAGE_NAME krpc_cnano)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE"
    "${CURRENT_INSTALLED_DIR}/share/nanopb/copyright"
)
