vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO diegonehab/luasocket
    REF 5b18e475f38fcf28429b1cc4b17baee3b9793a62 # accessed on 2020-09-14
    SHA512 bdf7086a0504b0072b9cfd1266fc4ae89504053801722859a426f567fca00ed76f4c295c2a3a968e93f0036d9b792cf97561e9baa82c09ea23999cfd473227eb
    HEAD_REF master)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

# Remove debug share
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(COPY "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/luasocket")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/luasocket/LICENSE" "${CURRENT_PACKAGES_DIR}/share/luasocket/copyright")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
# Handle socket dll name
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/socket/socket.core.dll" "${CURRENT_PACKAGES_DIR}/bin/socket/core.dll")
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/socket/socket.core.pdb" "${CURRENT_PACKAGES_DIR}/bin/socket/core.pdb")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/socket/socket.core.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/socket/core.dll")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/socket/socket.core.pdb" "${CURRENT_PACKAGES_DIR}/debug/bin/socket/core.pdb")

# Handle mime dll name
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/mime/mime.core.dll" "${CURRENT_PACKAGES_DIR}/bin/mime/core.dll")
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/mime/mime.core.pdb" "${CURRENT_PACKAGES_DIR}/bin/mime/core.pdb")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/mime/mime.core.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/mime/core.dll")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/mime/mime.core.pdb" "${CURRENT_PACKAGES_DIR}/debug/bin/mime/core.pdb")
endif()

# Allow empty include directory
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
