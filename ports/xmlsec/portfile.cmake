vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

string(REPLACE "." "_" release_tag "xmlsec_${VERSION}")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lsh123/xmlsec
    REF "${release_tag}"
    SHA512 6e41c35042e5a74e135cfb7468aa5c09b3c9ba684ab2431ecedce950f7c99c92fc8765c1c8c2ddfd87718bd00f4a287028227da1e987f2ef17ce2594356e81af
    HEAD_REF master
    PATCHES 
        pkgconfig_fixes.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG -DINSTALL_HEADERS_TOOLS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-xmlsec)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

# unofficial legacy usage
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/xmlsec-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/unofficial-xmlsec-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-xmlsec")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/Copyright" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
