string(REPLACE "." "_" VERSION "${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO munt/munt
    REF "libmt32emu_${VERSION}"
    SHA512 46c47438488613f9208de379bcba3becaf315dbc2248bd0f6db93f738c95a8d6d351f6c6e1857df2b2bf353b0f40752ab301fe3669d3a888a61408766618dda8
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/mt32emu"
    OPTIONS
        -Dlibmt32emu_SHARED:BOOL=${BUILD_SHARED}
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME MT32Emu CONFIG_PATH lib/cmake/MT32Emu)

vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/doc"
)

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/mt32emu/COPYING.txt"
    "${SOURCE_PATH}/mt32emu/COPYING.LESSER.txt"
    "${SOURCE_PATH}/mt32emu/src/sha1/sha1.h"
)
