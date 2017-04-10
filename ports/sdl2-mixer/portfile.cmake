include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/SDL2_mixer-2.0.1)
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.libsdl.org/projects/SDL_mixer/release/SDL2_mixer-2.0.1.zip"
    FILENAME "SDL2_mixer-2.0.1.zip"
    SHA512 7399f08c5b091698c90d49fcc2996677eae8a36f05a65b4470807c9cf2c04730669e0ca395893cfa49177a929f8c5b2b10b6c541ba2fe2646300dcdad4ec1d9e)

vcpkg_extract_source_archive(${ARCHIVE})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSDL_MIXER_ENABLE_MP3=ON       # smpeg2
        -DSDL_MIXER_ENABLE_FLAC=ON      # libflac
        -DSDL_MIXER_ENABLE_MOD=ON       # libmodplug
        -DSDL_MIXER_ENABLE_OGGVORBIS=ON # libvorbis 
    OPTIONS_DEBUG
        -DSDL_MIXER_SKIP_HEADERS=ON)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/COPYING.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/sdl2-mixer)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/sdl2-mixer/COPYING.txt ${CURRENT_PACKAGES_DIR}/share/sdl2-mixer/copyright)
