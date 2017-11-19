include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/SDL2_mixer-2.0.2)
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.libsdl.org/projects/SDL_mixer/release/SDL2_mixer-2.0.2.zip"
    FILENAME "SDL2_mixer-2.0.2.zip"
    SHA512 da0c27c560a153d57d69a1b6c58a288f017762afc654749957072900a904d3dac19a0efcb68516cb166546d29ff570462385016e0041dae6f393ccb4bbd2ffbc)

vcpkg_extract_source_archive(${ARCHIVE})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSDL_MIXER_ENABLE_MP3=ON       # mpg123
        -DSDL_MIXER_ENABLE_FLAC=ON      # libflac
        -DSDL_MIXER_ENABLE_MOD=ON       # libmodplug
        -DSDL_MIXER_ENABLE_OGGVORBIS=ON # libvorbis 
    OPTIONS_DEBUG
        -DSDL_MIXER_SKIP_HEADERS=ON)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/COPYING.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/sdl2-mixer)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/sdl2-mixer/COPYING.txt ${CURRENT_PACKAGES_DIR}/share/sdl2-mixer/copyright)
