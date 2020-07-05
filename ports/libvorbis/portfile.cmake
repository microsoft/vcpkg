vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/vorbis
    REF 4d963fe0b4ba3bdb45233de4b959ce2f36963f7a
    SHA512 c739cebf1a7ff4739447e899d3373e2fa7a0f3a87affd59c9c0c65d69e7611ceadcdcd1592c279e65123d7d2e1c9f8f8e7dee93def8753bcdd6d115677232d83
    HEAD_REF master
    PATCHES
        0001-Dont-export-vorbisenc-functions.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(
    CONFIG_PATH lib/cmake/Vorbis
    TARGET_PATH share/Vorbis
)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

vcpkg_copy_pdbs() 
