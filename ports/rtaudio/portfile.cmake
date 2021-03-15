vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO thestk/rtaudio
    REF 34a3752e0c8249dc1780d196cd24e745425f0c77
    SHA512 00fea107f409f6dc43154aaf69aeffa1a3385031778b5f7d1ae1cc8337ed4ab92a7917cc9eade848dedd746016b6eff6234088619cb8d6a9a3f26a63efde493e
    HEAD_REF master
)

if(VCPKG_CRT_LINKAGE STREQUAL static)
    set(RTAUDIO_STATIC_MSVCRT ON)
else()
    set(RTAUDIO_STATIC_MSVCRT OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DRTAUDIO_STATIC_MSVCRT=${RTAUDIO_STATIC_MSVCRT}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

# Version 5.1.0 has the license text embedded in the README.md, so we are including it as a standalone file in the vcpkg port
# Current master version of rtaudio has a LICENSE file which should be used instead for ports of future releases
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

