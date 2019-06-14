include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO diegonehab/luasocket
    REF 733af884f1aa18ff469bf3c4d18810e815853211
    SHA512 632d66a9460636758428261b5b0d8669a90492de716915c07d1d1bf66c795bc9599f9edcd4345bbc3ef06830d670303b6cfb56c206e022b4bc5307fec2a20395
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
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
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
endif()

# Allow empty include directory
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
