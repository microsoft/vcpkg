vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

string(REPLACE "." "_" release_tag "xmlsec-${VERSION}")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lsh123/xmlsec
    REF "${release_tag}"
    SHA512 c74c0854f0afdf97651cb8ae26430a43ebb7d849b7715fdec3abcd96e61f67f0d2bac82b68b10c97dc90ee52b14ba426bbf9413f71caa7de5fa6ecb945cba0d1
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

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/Copyright" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
