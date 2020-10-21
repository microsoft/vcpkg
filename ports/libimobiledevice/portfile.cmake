vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice-win32/libimobiledevice
    REF b30267ac1fb46f2b1d2d5e585aaa73c0f4ce8ad8 # v1.3.6
    SHA512 47912571726c38fe3c306a5e7c76b4042994b53a30794432a5af7eae5a30855d39828c52048b1a90b837306e6d5c447fc11d8521669258e76231cfdd6aef17d9
    HEAD_REF msvc-master
    PATCHES
        fix-functions-declaration.patch
)

configure_file(${CURRENT_PORT_DIR}/CMakeLists.txt ${SOURCE_PATH}/CMakeLists.txt COPYONLY)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
