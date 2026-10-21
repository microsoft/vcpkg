vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO coin3d/superglu
    REF "v${VERSION}"
    SHA512 ff1edb95192b4593e99106bf5d7fe30aabd8e42b21a6a02b2dcb2431b1388d87e7c1186a2291047f8a10897e872329e8dd993e89414e4d88f2e9e95c6a74fd52
    HEAD_REF master
    PATCHES
        change-output-name.patch
)

vcpkg_find_acquire_program(PERL)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSUPERGLU_BUILD_SHARED_LIBS=OFF
        "-DPERL_EXECUTABLE=${PERL}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/superglu-${VERSION})
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")