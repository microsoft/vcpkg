vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO serge1/ELFIO
    REF Release_3.10
    SHA512 f609fe5162d1609d1d65f441dbf01011ca5ae36195d8b3a74dec2b72891e9f8f90d3fdbc9bf893f7186494071606e898e5519fda18665fc88ae9781c504cd4a9)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/${PORT}/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
