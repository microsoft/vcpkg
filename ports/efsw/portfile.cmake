vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SpartanJ/efsw
    REF 6fb0c9ccd284445330723914249b7be46798ee76
    SHA512 5f31d8e52f3a4fc351ccf4ab6388ca347fb66694e280a3cee7eeef4ae4723cdca9cd2dbd65605cc2371b73e0c4e44bfaf70c6d18d33cd7b1a8a92721fa177113
    HEAD_REF master
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/thread_sync.patch
        ${CMAKE_CURRENT_LIST_DIR}/reproc_fork_interaction.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DVERBOSE=OFF
        -DBUILD_TEST_APP=OFF
		-DBUILD_SHARED_LIBS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/efsw)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
