vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO munt/munt
    REF libmt32emu_2_5_0
    SHA512 e86733bb26714a2a5f54a1b443db1e6f320bc3373dde6bbbe6662ecfb5b36c8ba0811919f2ddd54a11f264551add76e7032cd51f5803c502bfd4b1020fafb86b
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/mt32emu
    PREFER_NINJA
    OPTIONS
        -Dlibmt32emu_SHARED:BOOL=${BUILD_SHARED}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")


file(INSTALL ${SOURCE_PATH}/mt32emu/COPYING.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
