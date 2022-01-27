vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice-win32/libusbmuxd
    REF ac86b23f57879b8b702f3712ba66729008d059a3 # v1.2.219
    SHA512 ced85088bc6ebb416ccb635d6b4e79662fb34f427d869b64b61847e5fde7b4ae094cebb1f7916d9387c314aeb84106a618fbd7497dc4b36151b236dcb55bd0e4
    HEAD_REF msvc-master
    PATCHES fix-win-build.patch
)

configure_file(${CURRENT_PORT_DIR}/CMakeLists.txt ${SOURCE_PATH}/CMakeLists.txt COPYONLY)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
