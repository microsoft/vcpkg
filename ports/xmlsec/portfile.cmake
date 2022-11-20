vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lsh123/xmlsec
    REF d823da17c80b38ccc3c4262d7b2042b07e69e266 # xmlsec-1_2_34
    SHA512 10ca5cb948723fcf1531efaab547c0665bc323cd52906decd314e0c78fff46ac7bc51eba5177838fc7f081f74f5e4a202d765c17dd0da6e378798676773a68ce
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
