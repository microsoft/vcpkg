include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO diegonehab/luasocket
    REF c89a931cc31f219d51dd32a8a253d5ee3fbd31be
    SHA512 1769bc6aed41f129a7e7f8c64497476fc89dc69a227a4610c6330c3138b9cdc3c2fc87a925efc13ba840153b681cc4d66001faddb5b3085f430050c52bd5e564
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
