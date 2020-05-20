vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice-win32/libimobiledevice
    REF 37cb65f04249705eb5844821fd925b9edee8866c # v1.2.185
    SHA512 00a44de9552d3cf3daf3d490ad700188e20c72b24b8a6e9ca32d1d9fa53572479a5cbe85d130cd24fb1a2528c5e2cb238ab4caab35c5d93033c53b5c4c189bc6
    HEAD_REF msvc-master
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
