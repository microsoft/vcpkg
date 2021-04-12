vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mirror/ncurses
    REF  47d2fb4537d9ad5bb14f4810561a327930ca4280 # v6.2
    SHA512 e468904d3a10f7edfc060becbe261f46d9dd5f51eef3821dfeb3459e123a6af2dcb6c7d1399e914b29866ca8456c1e95d4ca9f61ca82ab9a3a2e2bc879cbcdca 
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/ncurses RENAME copyright)
