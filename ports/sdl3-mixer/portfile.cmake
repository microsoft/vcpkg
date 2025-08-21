vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libsdl-org/SDL_mixer
    REF "f9566f4dd643cd5dd6e136e4779fe49fa8c4e3d7"
    HEAD_REF main
    SHA512 b96783ce8898d3144af65a075bafe97b0438d015f071175ec21bc2b95ba6a1df88ec19e7155d0900a772aac94df488969af041fc8a6892c9ea85aaee67def1bf
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        fluidsynth SDLMIXER_MIDI
        fluidsynth SDLMIXER_MIDI_FLUIDSYNTH
        libflac SDLMIXER_FLAC
        libflac SDLMIXER_FLAC_LIBFLAC
        libmodplug SDLMIXER_MOD
        libmodplug SDLMIXER_MOD_MODPLUG
        mpg123 SDLMIXER_MP3
        mpg123 SDLMIXER_MP3_MPG123
        opusfile SDLMIXER_OPUS
    MAYBE_UNUSED_VARIABLES
        SDLMIXER_MP3_DRMP3
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
        -DSDLMIXER_VENDORED=OFF
        -DSDLMIXER_SAMPLES=OFF
        -DSDLMIXER_DEPS_SHARED=OFF
        -DSDLMIXER_OPUS_SHARED=OFF
        -DSDLMIXER_VORBIS_VORBISFILE_SHARED=OFF
        -DSDLMIXER_VORBIS="VORBISFILE"
        -DSDLMIXER_FLAC_DRFLAC=OFF
        -DSDLMIXER_MIDI_NATIVE=OFF
        -DSDLMIXER_MIDI_TIMIDITY=OFF
        -DSDLMIXER_MP3_DRMP3=OFF
        -DSDLMIXER_MOD_XMP_SHARED=${BUILD_SHARED}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(PACKAGE_NAME "SDL3_mixer" CONFIG_PATH "cmake")
else()
    vcpkg_cmake_config_fixup(PACKAGE_NAME "SDL3_mixer" CONFIG_PATH "lib/cmake/SDL3_mixer")
endif()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
