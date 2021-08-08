vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libb64/libb64
    REF v2.0.0.1
    SHA512 72c2fd4c81575b505f4851cd3820b6a2d8e78cd031a1ed138ffe5667ca711558f43b515428971966f7a73ace7c9951f1f0b39c362a59fe4691958875775cce23
    HEAD_REF master
    PATCHES "windows-fix.patch"
)

file(COPY ports/b64/CMakeLists.txt DESTINATION ${SOURCE_PATH}/)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

vcpkg_copy_pdbs()


# handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
