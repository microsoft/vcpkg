vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SpartanJ/efsw
    REF caacfa665ae6b4da265e7bf28fdf5bc8d343581e
    SHA512 23458ba287c220a682e39acfd2782c863ea9ca746740579b0310a5d8d9fc1d8a49b4f618a7d18bdab621b6808ee25255f651cc27bcbdd8ebd47003ace021570d
    HEAD_REF master
    PATCHES
        fix_dynamic_build.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DVERBOSE=ON
        -DBUILD_TEST_APP=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
