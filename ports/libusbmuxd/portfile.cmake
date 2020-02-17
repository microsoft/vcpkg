vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice-win32/libusbmuxd
    REF 65561d92bc4786599c90a257d856cede3519e432 # v1.2.185
    SHA512 b3bcf2a5d99a605431ba22fe5701068ea6a2c4284044412e3e1d3dc57bb7b42adac20cf21c0d8e09965c8e8f7bcffc72b5949eaefaa48d024d2a3cb16329ed78
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
