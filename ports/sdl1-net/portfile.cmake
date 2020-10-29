vcpkg_download_distfile(ARCHIVE
    URLS "https://www.libsdl.org/projects/SDL_net/release/SDL_net-1.2.8.tar.gz"
    FILENAME "SDL_net-1.2.8.tar.gz"
    SHA512 2766ca55343127c619958ab3a3ae3052a27a676839f10a158f7dfc071b8db38c2f1fc853e8add32b9fef94ab07eaa986f46a68e264e8087b57c990af30ea9a0b
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DSDL_NET_SKIP_HEADERS=ON)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/sdl1-net)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/sdl1-net/COPYING ${CURRENT_PACKAGES_DIR}/share/sdl1-net/copyright)
