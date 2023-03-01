
set(VERSION 2.0.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.libsdl.org/projects/smpeg/release/smpeg2-${VERSION}.tar.gz"
    FILENAME "smpeg2-${VERSION}.tar.gz"
    SHA512 80a779d01e7aa76778ef6ceea8041537db9e4b354df413214c4413c875cb98551891cef98fa0f057cc6a3222e4983da9ae65b86bdad2f87f9e2a6751837e2baf
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    SOURCE_BASE "${VERSION}"
    PATCHES 
        "001-correct-sdl-headers-dir.patch"
        "002-use-SDL2-headers.patch"
        "003-fix-double-ptr-to-int-comparison.patch"
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        -DSMPEG_SKIP_HEADERS=ON)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
