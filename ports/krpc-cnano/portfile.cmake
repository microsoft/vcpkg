vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/krpc/krpc/releases/download/v${VERSION}/krpc-cnano-${VERSION}.zip"
    FILENAME "krpc-cnano-${VERSION}.zip"
    SHA512 a7c678cec62944bbfab575f45808aa62df50fa4b6ba7d34e4732ff506d6065b7f4599fcc3ab40d0031d83038b1c71469522bc7ab0639338009d7a4e7886c8368
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
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/COPYING.LESSER"
    "${CURRENT_INSTALLED_DIR}/share/nanopb/copyright"
)
