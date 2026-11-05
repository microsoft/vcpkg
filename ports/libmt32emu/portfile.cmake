string(REPLACE "." "_" VERSION "${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO munt/munt
    REF "libmt32emu_${VERSION}"
    SHA512 91fc919e107b6985489386d960f84f2a72919fe088ab2e47e7f5c794a0781592f372428da6d17778eb9fd974d05ff2f9d2e70676477ae553642dff39209426bf
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
