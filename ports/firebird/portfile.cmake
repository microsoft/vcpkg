vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FirebirdSQL/firebird
    REF v5.0.0
    SHA512 8ba88b161df60b2759042a6119c5530dc9b3d9b6e1ec074906f17d13bf01f61c65becba732a75853321c6718b21ea51a3c61889c59e822a2cab6cb657975ca4d
    HEAD_REF master
    PATCHES
        windows-paths.diff
)

if(VCPKG_TARGET_IS_WINDOWS)
    include("${CMAKE_CURRENT_LIST_DIR}/windows/portfile.cmake")
else()
    include("${CMAKE_CURRENT_LIST_DIR}/posix/portfile.cmake")
endif()

# Copy common files

file(
    INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/builds/install/misc/IPLicense.txt"
        "${SOURCE_PATH}/builds/install/misc/IDPLicense.txt"
)

file(
    INSTALL "${CMAKE_CURRENT_LIST_DIR}/${PORT}-config.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)
