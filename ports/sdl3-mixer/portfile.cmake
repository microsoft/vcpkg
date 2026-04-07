vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libsdl-org/SDL_mixer
    REF "release-${VERSION}"
    HEAD_REF main
    SHA512 5f53ab3011e5727df51e405a687c0699e1530d4d597ab299ce8a6008a3c8295cf9170b072bf07ec49fb0af6eee757005a10cf67aa283b23575a3f58874c9b6be
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        fluidsynth SDLMIXER_MIDI
        fluidsynth SDLMIXER_MIDI_FLUIDSYNTH
        libflac SDLMIXER_FLAC
        libflac SDLMIXER_FLAC_LIBFLAC
        libxmp SDLMIXER_MOD
        libxmp SDLMIXER_MOD_XMP
        mpg123 SDLMIXER_MP3
        mpg123 SDLMIXER_MP3_MPG123
        opusfile SDLMIXER_OPUS
        libvorbis SDLMIXER_VORBIS_VORBISFILE
        wavpack SDLMIXER_WAVPACK
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
        -DSDLMIXER_TESTS=OFF
        -DSDLMIXER_VENDORED=OFF
        -DSDLMIXER_DEPS_SHARED=OFF
        -DSDLMIXER_OPUS_SHARED=OFF
        -DSDLMIXER_VORBIS_VORBISFILE_SHARED=OFF
        -DSDLMIXER_FLAC_DRFLAC=OFF
        -DSDLMIXER_MIDI_TIMIDITY=OFF
        -DSDLMIXER_MP3_DRMP3=OFF
        -DSDLMIXER_EXAMPLES=OFF
        -DSDLMIXER_GME=OFF
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
