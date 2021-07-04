#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO skypjack/uvw
    REF 77af4a3fc4d932a52652807506fc50d0e58e875c # v2.7.0_libuv_v1.39
    SHA512 b9ee4a60928fbcea84a9c551ce4d97095db68352546054116ecc8303eaeb46aecaef15ca2e5d3ebd14d8292be798fdea50b353ffdc727faa43c23cfd314ea407
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/uvw-config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/uvw/)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright/readme/package files
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/uvw RENAME copyright)
file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/uvw)
