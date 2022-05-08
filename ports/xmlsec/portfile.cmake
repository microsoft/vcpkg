vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lsh123/xmlsec
    REF e628e70040cb0d81a561462472806aeaac1d1bc7 #xmlsec-1_2_33
    SHA512 2d4485941d354160f7fabd84394c61eef9dcea8be572d78bf7da7370880747f86ff76127fa000f8b0de06f462abef17d653270dee680fa35d96cc8200fb4d1a6
    HEAD_REF master
    PATCHES 
        pkgconfig_fixes.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG -DINSTALL_HEADERS_TOOLS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/Copyright" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_copy_pdbs()
