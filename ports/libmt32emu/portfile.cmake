string(REPLACE "." "_" VERSION "${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO munt/munt
    REF "libmt32emu_${VERSION}"
    SHA512 b28df7f0d08c37afbc71f9a3c03094a3d95e085c35b5edd3a2521fe05bc545f57a9658d003440183fcec18adb16fd29ce99c8047f0b2e455583b9ad7eca4e128
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
