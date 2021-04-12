vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mirror/ncurses
    REF  47d2fb4537d9ad5bb14f4810561a327930ca4280 # v6.2
    SHA512 776558fdd911f0cc9e8d467bf8e00a1930d2e51bb8ccd5f36f95955fefecab65faf575a80fdaacfe83fd32808f8b9c2e0323b16823e0431300df7bc0c1dfde12
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/ncurses RENAME copyright)
