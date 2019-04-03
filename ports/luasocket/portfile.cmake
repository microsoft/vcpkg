include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO diegonehab/luasocket
    REF 288219fd6b53ce2e709745c9918aa4c4b7f715c9
    SHA512 f7b1f90437655352ab69a733bc2b2a0080d116fb8b6896fce0eb8ba6c593e2e3f64684c956d387a198d5aa48c4a9208531ab5e96805d92f0d4ca3ed46179be0b
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
