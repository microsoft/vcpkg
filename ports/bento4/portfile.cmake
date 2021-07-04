vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO axiomatic-systems/Bento4
    REF v1.5.1-628
    SHA512 2bf44f55307178cc9128e323904acbfaa2f88e06beff26cf27fc0a7707875942de89778a0ee1a8315ef2c3b19754edad77d32fdb74f3d651f03c2623e7a9122d 
    HEAD_REF master 
    PATCHES fix-install-and-c4996-error.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
