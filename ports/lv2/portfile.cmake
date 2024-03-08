vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lv2/lv2
    REF "v${VERSION}"
    SHA512 d63a223b1e1ab9282392637ea2878cfca5dc466553dcea45fb6d8bc5fe657d0705f01db45affcda29344166fba2738a33da5c15ef44ceec58989e406131e1ded
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(
    INSTALL "${SOURCE_PATH}/COPYING"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright
)
