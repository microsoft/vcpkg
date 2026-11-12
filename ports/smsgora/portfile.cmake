vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO TekservixHQ/smsgora-c
    REF "v${VERSION}"
    SHA512 f1d6c383aca903f959c172ce2f18712ada9c871dd6f6c063e771014015cf9b87e9a2f0cb17d75536882940008c53143c5cd692c9b41805942b020f279ff48ef5
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSMSGORA_BUILD_TESTS=OFF
        -DSMSGORA_BUILD_EXAMPLES=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/smsgora)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
