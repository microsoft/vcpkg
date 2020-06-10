vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GNOME/librsvg
    REF  2cbb0f7bf56666187993bd7ba688bf82d0c9a5c7 #2.40.20
    SHA512 776558fdd911f0cc9e8d467bf8e00a1930d2e51bb8ccd5f36f95955fefecab65faf575a80fdaacfe83fd32808f8b9c2e0323b16823e0431300df7bc0c1dfde12
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
configure_file(${CMAKE_CURRENT_LIST_DIR}/config.h.linux ${SOURCE_PATH}/config.h.linux COPYONLY)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-librsvg TARGET_PATH share/unofficial-librsvg)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

#vcpkg_test_cmake(PACKAGE_NAME unofficial-librsvg)
