set(SDL2_MIXER_VERSION 2.0.4)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.libsdl.org/projects/SDL_mixer/release/SDL2_mixer-${SDL2_MIXER_VERSION}.zip"
    FILENAME "SDL2_mixer-${SDL2_MIXER_VERSION}.zip"
    SHA512 359b4f9877804f9c4b3cb608ca6082aab684f07a20a816ab71c8cdf85d26f76d67eeb5aee44daf52b7935d82aa3b45941f8f53f07ca3dd5150d6c58ed99e1492
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${SDL2_MIXER_VERSION}
)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    mpg123 SDL_MIXER_ENABLE_MP3
    libflac SDL_MIXER_ENABLE_FLAC
    libmodplug SDL_MIXER_ENABLE_MOD
    libvorbis SDL_MIXER_ENABLE_OGGVORBIS
    opusfile SDL_MIXER_ENABLE_OPUS
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLIBRARY_SUFFIX=${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX} # It should always be dynamic suffix
    OPTIONS_DEBUG
        -DSDL_MIXER_SKIP_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/COPYING.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)