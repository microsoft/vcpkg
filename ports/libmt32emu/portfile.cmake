string(REPLACE "." "_" VERSION "${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO munt/munt
    REF libmt32emu_${VERSION}
    SHA512 9ec78d57d93bdac9ec7097b03eef7efb79bfa8837a9f04746a89f508adc6482f2da0977db3f7e5def6629cc613fa58c4bf23c752af251e417a5303cf14fe96ad
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/mt32emu"
    OPTIONS
        -Dlibmt32emu_SHARED:BOOL=${BUILD_SHARED}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME MT32Emu CONFIG_PATH lib/cmake/MT32Emu)

vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")


file(INSTALL "${SOURCE_PATH}/mt32emu/COPYING.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
