cmake_minimum_required(VERSION 3.1)
project(SDL2_MIXER C)

find_path(SDL_INCLUDE_DIR SDL.h PATH_SUFFIXES SDL2)
find_package(SDL2 CONFIG REQUIRED)
set(SDL_MIXER_INCLUDES ${SDL_INCLUDE_DIR})

set(SDL_MIXER_LIBRARIES SDL2::SDL2)

# builtin formats
set(SDL_MIXER_DEFINES MUSIC_WAV)

# MP3 support
if(SDL_MIXER_ENABLE_MP3)
    find_path(MPG123_INCLUDE_DIR mpg123.h)
    find_library(MPG123_LIBRARY NAMES libmpg123 mpg123)
    list(APPEND SDL_MIXER_INCLUDES ${MPG123_INCLUDE_DIR})
    list(APPEND SDL_MIXER_LIBRARIES ${MPG123_LIBRARY})
    list(APPEND SDL_MIXER_DEFINES MUSIC_MP3_MPG123)
endif()

# FLAC support
if(SDL_MIXER_ENABLE_FLAC)
    find_path(FLAC_INCLUDE_DIR FLAC/all.h)
    find_library(FLAC_LIBRARY FLAC)
    list(APPEND SDL_MIXER_INCLUDES ${FLAC_INCLUDE_DIR})
    list(APPEND SDL_MIXER_LIBRARIES ${FLAC_LIBRARY})
    list(APPEND SDL_MIXER_DEFINES MUSIC_FLAC)
endif()

# MOD support
if(SDL_MIXER_ENABLE_MOD)
    find_path(MODPLUG_INCLUDE_DIR libmodplug/modplug.h)
    find_library(MODPLUG_LIBRARY modplug)
    list(APPEND SDL_MIXER_INCLUDES ${MODPLUG_INCLUDE_DIR})
    list(APPEND SDL_MIXER_LIBRARIES ${MODPLUG_LIBRARY})
    list(APPEND SDL_MIXER_DEFINES MUSIC_MOD_MODPLUG)
endif()

# Ogg-Vorbis support
if(SDL_MIXER_ENABLE_OGGVORBIS)
    find_path(VORBIS_INCLUDE_DIR vorbis/codec.h)
    find_library(VORBISFILE_LIBRARY vorbisfile)
    list(APPEND SDL_MIXER_INCLUDES ${VORBIS_INCLUDE_DIR})
    list(APPEND SDL_MIXER_LIBRARIES ${VORBISFILE_LIBRARY})
    list(APPEND SDL_MIXER_DEFINES MUSIC_OGG)
endif()

# Opus support
if(SDL_MIXER_ENABLE_OPUS)
    find_path(OPUS_INCLUDE_DIR opus/opusfile.h)
    find_package(ogg CONFIG REQUIRED)
    find_package(Opus CONFIG REQUIRED)
    find_library(OPUSFILE_LIBRARY opusfile)
    list(APPEND SDL_MIXER_INCLUDES ${OPUS_INCLUDE_DIR})
    list(APPEND SDL_MIXER_LIBRARIES ${OPUSFILE_LIBRARY} Ogg::ogg Opus::opus)
    list(APPEND SDL_MIXER_DEFINES MUSIC_OPUS)
endif()

add_library(SDL2_mixer
    effect_position.c
    effect_stereoreverse.c
    effects_internal.c
    load_aiff.c
    load_voc.c
    mixer.c
    music.c
    music_cmd.c
    music_flac.c
    music_fluidsynth.c
    music_mad.c
    music_mikmod.c
    music_modplug.c
    music_mpg123.c
    music_ogg.c
    music_opus.c
    music_timidity.c
    music_wav.c
    version.rc)

if(WIN32)
    list(APPEND SDL_MIXER_DEFINES MUSIC_MID_NATIVE)
    target_sources(SDL2_mixer PRIVATE music_nativemidi.c native_midi/native_midi_common.c native_midi/native_midi_win32.c)
    target_link_libraries(SDL2_mixer ${SDL_MIXER_LIBRARIES} Winmm)
endif()

set_target_properties(SDL2_mixer PROPERTIES DEFINE_SYMBOL SDL2_EXPORTS)
target_compile_definitions(SDL2_mixer PRIVATE ${SDL_MIXER_DEFINES})
target_include_directories(SDL2_mixer PRIVATE ${SDL_MIXER_INCLUDES} ./native_midi)

install(TARGETS SDL2_mixer
    EXPORT SDL2_mixer
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib)

install(EXPORT SDL2_mixer
    DESTINATION share/sdl2-mixer/
    FILE sdl2-mixer-config.cmake
    NAMESPACE SDL2::
)

if(NOT SDL_MIXER_SKIP_HEADERS)
    install(FILES SDL_mixer.h DESTINATION include/SDL2)
endif()

message(STATUS "Link-time dependencies:")
foreach(LIBRARY ${SDL_MIXER_LIBRARIES})
    message(STATUS "  " ${LIBRARY})
endforeach()
