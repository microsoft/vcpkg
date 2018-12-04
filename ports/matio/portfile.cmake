include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tbeu/matio
    REF v1.5.13
    SHA512 8525ee2c3f0e5cccf3dbae888d09a9477cbd1f2b17160fd15cc8e18792b027954ac18404ea74465ec6b8b5d057661502b1fc31fa6d119113139004c1bce7f712
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/matio RENAME copyright)

vcpkg_copy_pdbs()
