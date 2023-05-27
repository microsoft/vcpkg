vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO WohlSoft/SDL-Mixer-X
    REF 1bd1111949036645e92cf0f7aa635e904c590318
    SHA512 b3c87580ff639b015d0e3f00d584878f141896ac812ec036945025416019f7849e952a76135095358f427eb2d04ed8f68fd9721e1869dade78517f7372ad2f9c
    HEAD_REF master
    PATCHES
        fix-dependencies.patch
)

file(REMOVE
    "${SOURCE_PATH}/cmake/find/FindOGG.cmake" # Conflicts with official configurations
    "${SOURCE_PATH}/cmake/find/FindFFMPEG.cmake" # Using FindFFMPEG.cmake provided by vcpkg
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        libvorbis   USE_OGG_VORBIS
        opusfile    USE_OPUS
        libflac     USE_FLAC
        wavpack     USE_WAVPACK
        mpg123      USE_MP3_MPG123
        libmodplug  USE_MODPLUG
        libxmp      USE_XMP
        libgme      USE_GME
        ffmpeg      USE_FFMPEG
        cmd         USE_CMD
        libadlmidi  USE_MIDI_ADLMIDI
        libopnmidi  USE_MIDI_OPNMIDI
        timidity    USE_MIDI_TIMIDITY
        fluidsynth  USE_MIDI_FLUIDSYNTH
        nativemidi  USE_MIDI_NATIVE_ALT
        nativemidi  USE_MIDI_NATIVE
)

if("libadlmidi"     IN_LIST FEATURES OR 
    "libopnmidi"    IN_LIST FEATURES OR 
    "timidity"      IN_LIST FEATURES OR 
    "fluidsynth"    IN_LIST FEATURES OR 
    "nativemidi"    IN_LIST FEATURES)
    set(USE_MIDI ON)
else()
    set(USE_MIDI OFF)
endif()

if("fluidsynth" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PKGCONFIG)
    list(APPEND EXTRA_OPTIONS "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        ${EXTRA_OPTIONS}
        -DMIXERX_ENABLE_GPL=ON
        -DMIXERX_ENABLE_LGPL=ON
        -DUSE_SYSTEM_SDL2=ON
        -DUSE_SYSTEM_AUDIO_LIBRARIES=ON
        -DUSE_OGG_VORBIS_STB=OFF
        -DUSE_DRFLAC=OFF
        -DUSE_MP3_DRMP3=OFF
        -DUSE_FFMPEG_DYNAMIC=OFF
        -DUSE_MIDI=${USE_MIDI}
        -DUSE_MIDI_EDMIDI=OFF
        -DUSE_MIDI_FLUIDLITE=OFF
    MAYBE_UNUSED_VARIABLES
        USE_FFMPEG_DYNAMIC
        USE_CMD
        USE_MIDI_NATIVE
        USE_MIDI_NATIVE_ALT
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME SDL2_mixer_ext
    CONFIG_PATH lib/cmake/SDL2_mixer_ext)

vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/include"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

set(LICENSE_FILES
    "${SOURCE_PATH}/COPYING.txt"
    "${SOURCE_PATH}/GPLv2.txt"
    "${SOURCE_PATH}/GPLv3.txt"
    "${SOURCE_PATH}/SDL2_mixer_ext.License.txt"
)
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
