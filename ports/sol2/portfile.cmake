vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ThePhD/sol2
    REF v3.3.0
    SHA512 f1eba8f9ea270a3a3fff9c7a036d130ec848d065e54a8aefd2a19ad7f17dcb6b5744d979fac54c765e8317a4cdcf72e1b9d622d114f48c6502cf2db900c8d4a3 
    HEAD_REF develop
    PATCHES fix-namespace.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/sol2)

file(
    REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/debug"
        "${CURRENT_PACKAGES_DIR}/lib"
        "${CURRENT_PACKAGES_DIR}/include"
)

file(INSTALL "${SOURCE_PATH}/include/sol" DESTINATION "${CURRENT_PACKAGES_DIR}/include/")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_fixup_pkgconfig()
