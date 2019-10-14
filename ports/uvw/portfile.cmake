#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO skypjack/uvw
    REF 6ce60d4088bddce4d38a0aa81f99b03879d2f471
    SHA512 125b517a68f7804ea895fe7f1ca9c63139a3855ef47d16de631ccfda9a2cb8217b5f7f489ed463f72267c6f55718045c60da52e97936ce39d9f1ebe7232b4ea4
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
