vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libsdl-org/SDL_mixer
    REF "release-${VERSION}"
    SHA512 74c2b449e8a9928679d42e25bd7a5967e41fe9d51732f26197c6bbe1db9170be784125b7f268476050017f3dc970497e09a0409d50731026a18355375d0369ce
    PATCHES 
        fix-pkg-prefix.patch 
        fix-pkgconfig.patch 
        fix-deps-targets.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        fluidsynth SDL2MIXER_MIDI
        fluidsynth SDL2MIXER_MIDI_FLUIDSYNTH
        libflac SDL2MIXER_FLAC
        libflac SDL2MIXER_FLAC_LIBFLAC
        libmodplug SDL2MIXER_MOD
        libmodplug SDL2MIXER_MOD_MODPLUG
        mpg123 SDL2MIXER_MP3
        mpg123 SDL2MIXER_MP3_MPG123
        opusfile SDL2MIXER_OPUS
)

if("fluidsynth" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PKGCONFIG)
    list(APPEND EXTRA_OPTIONS "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        ${EXTRA_OPTIONS}
        -DSDL2MIXER_VENDORED=OFF
        -DSDL2MIXER_SAMPLES=OFF
        -DSDL2MIXER_DEPS_SHARED=OFF
        -DSDL2MIXER_OPUS_SHARED=OFF
        -DSDL2MIXER_VORBIS_VORBISFILE_SHARED=OFF
        -DSDL2MIXER_VORBIS="VORBISFILE"
        -DSDL2MIXER_FLAC_DRFLAC=OFF
        -DSDL2MIXER_MIDI_NATIVE=OFF
        -DSDL2MIXER_MIDI_TIMIDITY=OFF
        -DSDL2MIXER_MP3_DRMP3=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME "SDL2_mixer"
    CONFIG_PATH "lib/cmake/SDL2_mixer"
)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
