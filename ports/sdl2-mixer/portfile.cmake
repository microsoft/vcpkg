vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libsdl-org/SDL_mixer
    REF release-2.6.1
    SHA512 5ea074162e29aeab4faad64abf8cecb03f9cf6cac16940633d782d8299434a585bbdd11c932fa080b7cfab9ff9344eb9233d35ec755a92c4600411cc5817f21a
    PATCHES fix-pkg-prefix.patch fix-pkgconfig.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        fluidsynth SDL2MIXER_MIDI_FLUIDSYNTH
        libflac SDL2MIXER_FLAC_LIBFLAC
        libmodplug SDL2MIXER_MOD_MODPLUG
        libvorbis SDL2MIXER_VORBIS_VORBISFILE
        mpg123 SDL2MIXER_MP3_MPG123
        nativemidi SDL2MIXER_MIDI_NATIVE
        opusfile SDL2MIXER_OPUS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS "-DSDL2MIXER_VENDORED=OFF" ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME "SDL2_mixer"
    CONFIG_PATH "lib/cmake/SDL2_mixer"
)
vcpkg_fixup_pkgconfig()

file(
    INSTALL "${SOURCE_PATH}/LICENSE.txt"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
