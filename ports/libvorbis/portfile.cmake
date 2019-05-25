include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/vorbis
    REF 9eadeccdc4247127d91ac70555074239f5ce3529
    SHA512 26d6826eba57fd47ebf426ba5a0c961c87ff62e2bb4185190e4985de9ac49aa493f77a1bd01d3d0757eb89a8494ba7de3a506f76bf5c8942ac1de3f75746a301
    HEAD_REF master
    PATCHES
        0001-Dont-export-vorbisenc-functions.patch
        0002-Allow-deprecated-functions.patch
        ogg.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/libvorbis/copyright COPYONLY)

vcpkg_copy_pdbs() 
