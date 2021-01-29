vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice-win32/libimobiledevice
    REF 348aec1f714f77c717141f70869ac7c996c3c6fb # v1.3.6 + patches
    SHA512 fc7924667c3cb07025fd25ff94610ae57a90a8fd4502393e89993bfcd13c5e0c609efbf0343f344f59a8520ba4f7805925fea4c06d20ac1680f63f16aac12542
    HEAD_REF msvc-master
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
