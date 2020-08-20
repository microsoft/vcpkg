vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/vorbis
    REF v1.3.7
    SHA512 bfb6f5dbfd49ed38b2b08b3667c06d02e68f649068a050f21a3cc7e1e56b27afd546aaa3199c4f6448f03f6e66a82f9a9dc2241c826d3d1d4acbd38339b9e9fb
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

if(WIN32 AND (NOT MINGW))
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/vorbis.pc" "-lm" "")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/vorbis.pc" "-lm" "")
endif()
vcpkg_fixup_pkgconfig()
