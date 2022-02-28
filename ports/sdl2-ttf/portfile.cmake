set(VERSION 2.0.15)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-${VERSION}.tar.gz"
    FILENAME "SDL2_ttf-${VERSION}.tar.gz"
    SHA512 30d685932c3dd6f2c94e2778357a5c502f0421374293d7102a64d92f9c7861229bf36bedf51c1a698b296a58c858ca442d97afb908b7df1592fc8d4f8ae8ddfd
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${VERSION}
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DSDL_TTF_SKIP_HEADERS=ON)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(COPY ${SOURCE_PATH}/COPYING.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/sdl2-ttf)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/sdl2-ttf/COPYING.txt ${CURRENT_PACKAGES_DIR}/share/sdl2-ttf/copyright)
