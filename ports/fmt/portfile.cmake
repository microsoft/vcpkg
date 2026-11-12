vcpkg_download_distfile(FMT_BACKPORT_4813_PATCH
    URLS https://github.com/fmtlib/fmt/commit/588b3a0f8f6a8bcf2a959cae882d5b2703e86737.patch?full_index=1
    FILENAME fmt-backport-4813.patch
    SHA512 afda8fdfcdcb4b0dd5df4d4dae96a57a85fb9c4b65d0b49d51258f0913d4aed93ed146ebf96ed7b277490b1dde6c7117f43332013071441a96c3147520de8368
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fmtlib/fmt
    REF "${VERSION}"
    SHA512 d00479330c8b8c6a61a9420ac86c855964c3b611c0989158921a1ff7d1cac09f91cdec56219aebfbca0c47a3bdea98139620d45edaf14641b73288dcb3a6cc1c
    HEAD_REF master
    PATCHES
        "${FMT_BACKPORT_4813_PATCH}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFMT_CMAKE_DIR=share/fmt
        -DFMT_TEST=OFF
        -DFMT_DOC=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
