set(VERSION 1.0.4)

vcpkg_download_distfile(ARCHIVE
    URLS "http://www.ferzkopp.net/Software/SDL2_gfx/SDL2_gfx-${VERSION}.zip"
    FILENAME "SDL2_gfx-${VERSION}.zip"
    SHA512 213b481469ba2161bd8558a7a5427b129420193b1c3895923d515f69f87991ed2c99bbc44349c60b4bcbb7d7d2255c1f15ee8a3523c26502070cfaacccaa5242
)

vcpkg_extract_source_archive(
    SOURCE_PATH 
    ARCHIVE ${ARCHIVE}
    SOURCE_BASE "${VERSION}"
    PATCHES
        001-lrint-arm64.patch
        002-use-the-lrintf-intrinsic.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG -DSDL_GFX_SKIP_HEADERS=1
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_copy_pdbs()