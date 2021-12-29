# volk is not prepared to be a DLL.
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeux/volk
    REF 5a605f5d6997bd929b666700a36ca3d9bd1d7a47
    SHA512 ed6faf13828f3e47c4f12f8d19952c94589420539e98405bf2a4b7959518357dcc2f210746f3683d3862ac8c80821f3c863d49f4625e2dac85d2a680567e4f00
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DVOLK_INSTALL=ON
)
vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/volk)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Put the file containing the license where vcpkg expects it
file(COPY ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/volk/)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/volk/README.md ${CURRENT_PACKAGES_DIR}/share/volk/copyright)
