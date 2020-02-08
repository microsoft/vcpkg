vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice-win32/libusbmuxd
    REF b9643ca81b8274fbb2411d3c66c4edf103f6a711 # v1.2.137
    SHA512 f4c9537349bfac2140c809be24cc573d92087a57f20d90e2abd46d0a2098e31ccd283ab776302b61470fb08d45f8dc2cfb8bd8678cba7db5b2a9b51c270a3cc8
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

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
