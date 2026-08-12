vcpkg_download_distfile(ARCHIVE
    URLS https://repo.or.cz/libtar.git/snapshot/6d0ab4c78e7a8305c36a0c3d63fd25cd1493de65.tar.gz
    FILENAME libtar-6d0ab4c78e7a8305c36a0c3d63fd25cd1493de65.tar.gz
    SHA512 907d98ea2bd2e2a43604243fc7fd6c252aa02c3fdd79e21f2a784adf821cb18107e6e23a25ad0c64329fbe84e859da5c807272759a8bcd85a37b929c80af4a13
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    OPTIONS
        ac_cv_prog_cc_c23=no
)

set(install_options)
if(VCPKG_CROSSCOMPILING)
    # Avoid using the host strip tool on cross-compiled target binaries.
    list(APPEND install_options "INSTALL_PROGRAM='$(INSTALL)'")
endif()

vcpkg_make_install(OPTIONS ${install_options})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"  "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYRIGHT")
