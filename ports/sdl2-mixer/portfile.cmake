vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libsdl-org/SDL_mixer
    REF "release-${VERSION}"
    SHA512 653ec1f0af0b749b9ed0acd3bfcaa40e1e1ecf34af3127eb74019502ef42a551de226daef4cc89e6a51715f013e0ba0b1e48ae17d6aeee931271f2d10e82058a
    PATCHES 
        fix-pkg-prefix.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        fluidsynth SDL2MIXER_MIDI_FLUIDSYNTH
        libflac SDL2MIXER_FLAC
        libflac SDL2MIXER_FLAC_LIBFLAC
        libmodplug SDL2MIXER_MOD
        libmodplug SDL2MIXER_MOD_MODPLUG
        mpg123 SDL2MIXER_MP3
        mpg123 SDL2MIXER_MP3_MPG123
        timidity SDL2MIXER_MIDI_TIMIDITY
        wavpack SDL2MIXER_WAVPACK
        wavpack SDL2MIXER_WAVPACK_DSD
        opusfile SDL2MIXER_OPUS
)

if("fluidsynth" IN_LIST FEATURES OR "timidity" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DSDL2MIXER_MIDI=ON")
else()
    list(APPEND FEATURE_OPTIONS "-DSDL2MIXER_MIDI=OFF")
endif()

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

set(debug_libname "SDL2_mixerd")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/SDL2_mixer.pc" "-lSDL2_mixer" "-lSDL2_mixer-static")
    set(debug_libname "SDL2_mixer-staticd")
endif()

if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/SDL2_mixer.pc" "-lSDL2_mixer" "-l${debug_libname}")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
