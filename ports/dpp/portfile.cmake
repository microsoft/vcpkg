vcpkg_download_distfile(DPP_BACKPORT_1636_PATCH
    URLS https://github.com/brainboxdotcc/DPP/commit/5365da807ca589cb07c1686540e3f5f0260511a1.patch?full_index=1
    FILENAME dpp_backport_1636.patch
    SHA512 c0ef265811e3f4719c22d857f9a70cad3540f02a92215807aeca3337fd86d39ab3c7cb9d01db10f4ac2ce5a4a920593fea1f9169cee5b4f768e5595f6c6c1d73
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO brainboxdotcc/DPP
    REF "v${VERSION}"
    SHA512 4da74166ed68730ee60435fcac8ed79f206968a07c21228db14a7c1e7a39c922df7a8088276528b620d285d34529e2ce61f7bb03eccef8fea6231e81537d874d
    PATCHES
        "${DPP_BACKPORT_1636_PATCH}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DDPP_USE_EXTERNAL_JSON=ON
        -DDPP_BUILD_TEST=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(NO_PREFIX_CORRECTION)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share/dpp"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
