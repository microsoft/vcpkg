set(VCPKG_POLICY_ALLOW_DEBUG_SHARE enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FirebirdSQL/firebird
    REF v5.0.3
    SHA512 73bbc54342cff68adad66c3b7b9a22b4392ee390b745bda76b03f71a681a6a04337f3f904f2ed4504665bd1a037d68351124fa7c20bed07e22304f14dd54e69f
    HEAD_REF master
    PATCHES
        windows-paths.diff
        posix-support-for-static-fbclient.patch
        windows-support-for-static-fbclient.patch
        osx-unvcpkg.patch
        windows-timeout.patch
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
