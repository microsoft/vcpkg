vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

string(REPLACE "." "_" release_tag "xmlsec-${VERSION}")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lsh123/xmlsec
    REF "${release_tag}"
    SHA512 9a679fec678912ba0566fb108e2782de0e66d4b9ca335b55460ff7ca7dc47193a3396b43d0d2c2a014aab7ffaf527dc3604bc05fd5426841fd0a5dae634abc1e
    HEAD_REF master
    PATCHES 
        pkgconfig_fixes.patch
        fix-size-max.patch # https://github.com/lsh123/xmlsec/pull/412
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG -DINSTALL_HEADERS_TOOLS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/Copyright" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
