vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libsdl-org/SDL_mixer
    REF "release-${VERSION}"
    SHA512 e4c9a4418725ce019bb62216c8fd484cf04b34e2099af633d4c84e0e558fe6ba1921e791c5dde319266ffe3a1237f887871c819a249a8df7e9440c36fce181da
    PATCHES 
        fix-pkg-prefix.patch
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
        wavpack SDL2MIXER_WAVPACK
        wavpack SDL2MIXER_WAVPACK_DSD
        opusfile SDL2MIXER_OPUS
)

if("fluidsynth" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PKGCONFIG)
    list(APPEND EXTRA_OPTIONS "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}")
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

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
        -DSDL2MIXER_MOD_XMP_SHARED=${BUILD_SHARED}
    MAYBE_UNUSED_VARIABLES
        SDL2MIXER_MP3_DRMP3
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME "SDL2_mixer"
    CONFIG_PATH "lib/cmake/SDL2_mixer"
)
vcpkg_fixup_pkgconfig()

if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/SDL2_mixer.pc" "-lSDL2_mixer" "-lSDL2_mixerd")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
