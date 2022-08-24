vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lunarmodules/luasocket
    REF v3.0.0
    SHA512 4f93d6c0b602333df50ee4f939cd0419243f6de333472ffebf99334e301143e8cdee3bc1655c29f81608622d6e7850a9bcf6929a6d4748210a70cdb8218a1ec6
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
    if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/socket/socket.core.pdb")
        file(RENAME "${CURRENT_PACKAGES_DIR}/bin/socket/socket.core.pdb" "${CURRENT_PACKAGES_DIR}/bin/socket/core.pdb")
    endif()
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/socket/socket.core.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/socket/core.dll")
    if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/bin/socket/socket.core.pdb")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/socket/socket.core.pdb" "${CURRENT_PACKAGES_DIR}/debug/bin/socket/core.pdb")
    endif()

# Handle mime dll name
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/mime/mime.core.dll" "${CURRENT_PACKAGES_DIR}/bin/mime/core.dll")
    if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/mime/mime.core.pdb")
        file(RENAME "${CURRENT_PACKAGES_DIR}/bin/mime/mime.core.pdb" "${CURRENT_PACKAGES_DIR}/bin/mime/core.pdb")
    endif()
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/mime/mime.core.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/mime/core.dll")
    if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/bin/mime/mime.core.pdb")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/mime/mime.core.pdb" "${CURRENT_PACKAGES_DIR}/debug/bin/mime/core.pdb")
    endif()
endif()

# Allow empty include directory
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
