include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO diegonehab/luasocket
    REF 652959890943c34d7180cae372339b91e62f0d7b
    SHA512 8666e3dec0a3a0429e59a66c79b167f88b05a2a0b2c7f5456754cb5c505bcf8c39c4d358880a2f78a488ad07bee4e6e5b9a6a63c2affcee788091dee15ed2f6a
    HEAD_REF master)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# Remove debug share
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/luasocket)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/luasocket/LICENSE ${CURRENT_PACKAGES_DIR}/share/luasocket/copyright)

# Handle socket dll name
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/socket/socket.core.dll ${CURRENT_PACKAGES_DIR}/bin/socket/core.dll)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/socket/socket.core.pdb ${CURRENT_PACKAGES_DIR}/bin/socket/core.pdb)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/bin/socket/socket.core.dll ${CURRENT_PACKAGES_DIR}/debug/bin/socket/core.dll)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/bin/socket/socket.core.pdb ${CURRENT_PACKAGES_DIR}/debug/bin/socket/core.pdb)

# Handle mime dll name
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/mime/mime.core.dll ${CURRENT_PACKAGES_DIR}/bin/mime/core.dll)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/mime/mime.core.pdb ${CURRENT_PACKAGES_DIR}/bin/mime/core.pdb)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/bin/mime/mime.core.dll ${CURRENT_PACKAGES_DIR}/debug/bin/mime/core.dll)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/bin/mime/mime.core.pdb ${CURRENT_PACKAGES_DIR}/debug/bin/mime/core.pdb)

# Allow empty include directory
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
