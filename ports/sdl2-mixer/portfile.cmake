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
    PATCHES
        fix-featurempg123.patch
)

if ("dynamic-load" IN_LIST FEATURES)
    if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
        message("Building static library, disable dynamic loading")
    elseif (NOT "mpg123" IN_LIST FEATURES
            AND NOT "libflac" IN_LIST FEATURES
            AND NOT "libmodplug" IN_LIST FEATURES
            AND NOT "libvorbis" IN_LIST FEATURES
            AND NOT "opusfile" IN_LIST FEATURES
           )
        message("No features selected, dynamic loading will not be enabled")
    endif()
endif()

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        dynamic-load SDL_DYNAMIC_LOAD
        mpg123 SDL_MIXER_ENABLE_MP3
        libflac SDL_MIXER_ENABLE_FLAC
        libmodplug SDL_MIXER_ENABLE_MOD
        libvorbis SDL_MIXER_ENABLE_OGGVORBIS
        opusfile SDL_MIXER_ENABLE_OPUS
        nativemidi SDL_MIXER_ENABLE_NATIVEMIDI
        fluidsynth SDL_MIXER_ENABLE_FLUIDSYNTH
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLIBRARY_SUFFIX=${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX} # It should always be dynamic suffix
    OPTIONS_DEBUG
        -DSDL_MIXER_SKIP_HEADERS=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/COPYING.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)