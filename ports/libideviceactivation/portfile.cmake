vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice-win32/libideviceactivation
    REF de6008a6bd66a96bb11468b8b137704f0fef2c54 # v1.2.137
    SHA512 cdf72702c465cb3e405db067fa96e2979b8c32e7798bcdb9e7286c4bc9392639cb0d31622c321453f635ef5212e645d300f3b420a847fb16fa05425c4882be95
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
