vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO thestk/rtaudio
    REF 5.1.0
    SHA512 338a3a14cd4ea665ac7e94a275cb017bffd87cb10eb8ab6784fad320345ee828b8874439edd08c39efa48736edf9aa0622620784adc320473b03a8f81e17fff6
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

# Version 5.1.0 has the license text embedded in the README.md, so we are including it as a standalone file in the vcpkg port
# Current master version of rtaudio has a LICENSE file which should be used instead for ports of future releases
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

