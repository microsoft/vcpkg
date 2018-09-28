include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/vorbis
    REF 112d3bd0aaacad51305e1464d4b381dabad0e88b
    SHA512 df20e072a5e024ca2b8fc0e2890bb8968c0c948a833149a6026d2eaf6ab57b88b6d00d0bfb3b8bfcf879c7875e7cfacb8c6bf454bfc083b41d76132c567ff7ae
    HEAD_REF master
    PATCHES
        0001-Dont-export-vorbisenc-functions.patch
        0002-Allow-deprecated-functions.patch
        targets.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-vorbis TARGET_PATH share/unofficial-vorbis)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/libvorbis/copyright COPYONLY)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/unofficial-vorbis-config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/unofficial-vorbis)

vcpkg_copy_pdbs()

vcpkg_test_cmake(PACKAGE_NAME unofficial-vorbis)
