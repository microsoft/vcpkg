include(vcpkg_common_functions)

set(LUASOCKET_VERSION 2017.05.25.5a17f79b0301f0a1b4c7f1c73388757a7e2ed309)
set(LUASOCKET_REVISION 5a17f79b0301f0a1b4c7f1c73388757a7e2ed309)
set(LUASOCKET_HASH 82a827956d992c7d67a3e9aed18db0cdce34f32e5b49c44976c1d19cb96ff1c10121abb2130d306cf51125fdc5eb3be0cc491a3862e5a8fde3d944ba3b4a94b7)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/luasocket-${LUASOCKET_VERSION})
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO diegonehab/luasocket
    REF ${LUASOCKET_REVISION}
    SHA512 ${LUASOCKET_HASH}
    HEAD_REF master)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS)

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
