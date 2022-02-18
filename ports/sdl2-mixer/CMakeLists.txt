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
    list(APPEND SDL_MIXER_DEFINES MUSIC_MP3_MPG123)
    list(APPEND SDL_MIXER_LIBRARIES ${MPG123_LIBRARY})
    if (SDL_DYNAMIC_LOAD)
        get_filename_component(MPG123_LIBRARY_NAME "${MPG123_LIBRARY}" NAME_WE)
        list(APPEND SDL_MIXER_LOAD_DEFINES -DMPG123_DYNAMIC="${MPG123_LIBRARY_NAME}${LIBRARY_SUFFIX}")
    endif()
endif()

# FLAC support
if(SDL_MIXER_ENABLE_FLAC)
    find_path(FLAC_INCLUDE_DIR FLAC/all.h)
    find_library(FLAC_LIBRARY FLAC)
    list(APPEND SDL_MIXER_INCLUDES ${FLAC_INCLUDE_DIR})
    list(APPEND SDL_MIXER_DEFINES MUSIC_FLAC)
    list(APPEND SDL_MIXER_LIBRARIES ${FLAC_LIBRARY})
    if (SDL_DYNAMIC_LOAD)
        get_filename_component(FLAC_LIBRARY_NAME "${FLAC_LIBRARY}" NAME_WE)
        list(APPEND SDL_MIXER_LOAD_DEFINES -DFLAC_DYNAMIC="${FLAC_LIBRARY_NAME}${LIBRARY_SUFFIX}")
    endif()
endif()

# MOD support
if(SDL_MIXER_ENABLE_MOD)
    find_path(MODPLUG_INCLUDE_DIR libmodplug/modplug.h)
    find_library(MODPLUG_LIBRARY modplug)
    list(APPEND SDL_MIXER_INCLUDES ${MODPLUG_INCLUDE_DIR})
    list(APPEND SDL_MIXER_DEFINES MUSIC_MOD_MODPLUG)
    list(APPEND SDL_MIXER_LIBRARIES ${MODPLUG_LIBRARY})
    if (SDL_DYNAMIC_LOAD)
        get_filename_component(MODPLUG_LIBRARY_NAME "${MODPLUG_LIBRARY}" NAME_WE)
        list(APPEND SDL_MIXER_LOAD_DEFINES -DMODPLUG_DYNAMIC="${MODPLUG_LIBRARY_NAME}${LIBRARY_SUFFIX}")
    endif()
endif()

# Ogg-Vorbis support
if(SDL_MIXER_ENABLE_OGGVORBIS)
    find_path(VORBIS_INCLUDE_DIR vorbis/codec.h)
    find_library(VORBISFILE_LIBRARY vorbisfile)
    list(APPEND SDL_MIXER_INCLUDES ${VORBIS_INCLUDE_DIR})
    list(APPEND SDL_MIXER_DEFINES MUSIC_OGG)
    list(APPEND SDL_MIXER_LIBRARIES ${VORBISFILE_LIBRARY})
    if (SDL_DYNAMIC_LOAD)
        get_filename_component(VORBISFILE_LIBRARY_NAME "${VORBISFILE_LIBRARY}" NAME_WE)
        list(APPEND SDL_MIXER_LOAD_DEFINES -DOGG_DYNAMIC="${VORBISFILE_LIBRARY_NAME}${LIBRARY_SUFFIX}")
    endif()
endif()

# Opus support
if(SDL_MIXER_ENABLE_OPUS)
    find_path(OPUS_INCLUDE_DIR opus/opusfile.h)
    find_library(OPUSFILE_LIBRARY opusfile)
    list(APPEND SDL_MIXER_INCLUDES ${OPUS_INCLUDE_DIR})
    list(APPEND SDL_MIXER_DEFINES MUSIC_OPUS)
    list(APPEND SDL_MIXER_LIBRARIES ${OPUSFILE_LIBRARY})
    if (SDL_DYNAMIC_LOAD)
        get_filename_component(OPUSFILE_LIBRARY_NAME "${OPUSFILE_LIBRARY}" NAME_WE)
        list(APPEND SDL_MIXER_LOAD_DEFINES -DOPUS_DYNAMIC="${OPUSFILE_LIBRARY_NAME}${LIBRARY_SUFFIX}")
    endif()
endif()

# Fluidsynth support
if(SDL_MIXER_ENABLE_FLUIDSYNTH)
    find_path(FLUIDSYNTH_INCLUDE_DIR fluidsynth.h)
    find_library(FLUIDSYNTH_LIBRARY fluidsynth)
    list(APPEND SDL_MIXER_INCLUDES ${FLUIDSYNTH_INCLUDE_DIR})
    list(APPEND SDL_MIXER_DEFINES MUSIC_MID_FLUIDSYNTH)
    list(APPEND SDL_MIXER_LIBRARIES ${FLUIDSYNTH_LIBRARY})
    if (SDL_DYNAMIC_LOAD)
        get_filename_component(FLUIDSYNTH_LIBRARY_NAME "${FLUIDSYNTH_LIBRARY}" NAME_WE)
        list(APPEND SDL_MIXER_LOAD_DEFINES -DFLUIDSYNTH_DYNAMIC="${FLUIDSYNTH_LIBRARY_NAME}${LIBRARY_SUFFIX}")
    endif()
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

if((WIN32 OR APPLE) AND SDL_MIXER_ENABLE_NATIVEMIDI)
    list(APPEND SDL_MIXER_DEFINES MUSIC_MID_NATIVE)
    target_sources(SDL2_mixer PRIVATE music_nativemidi.c native_midi/native_midi_common.c)
    target_link_libraries(SDL2_mixer ${SDL_MIXER_LIBRARIES})
    if(WIN32)
        target_sources(SDL2_mixer PRIVATE native_midi/native_midi_win32.c)
        target_link_libraries(SDL2_mixer Winmm)
    elseif(APPLE)
        target_sources(SDL2_mixer PRIVATE native_midi/native_midi_macosx.c)
    endif()
endif()

set_target_properties(SDL2_mixer PROPERTIES DEFINE_SYMBOL DLL_EXPORT)
target_compile_definitions(SDL2_mixer PRIVATE ${SDL_MIXER_DEFINES} ${SDL_MIXER_LOAD_DEFINES})
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

set(prefix "")
set(exec_prefix [[${prefix}]])
set(libdir [[${prefix}/lib]])
set(includedir [[${prefix}/include]])
set(PACKAGE "SDL2_mixer")
file(READ "SDL_mixer.h" header_contents)
#    #define SDL_MIXER_MAJOR_VERSION 2
#    #define SDL_MIXER_MINOR_VERSION 0
#    #define SDL_MIXER_PATCHLEVEL    5
string(REGEX MATCH "define *SDL_MIXER_MAJOR_VERSION *([0-9]+)" _ "${header_contents}")
set(VERSION ${CMAKE_MATCH_1})
string(REGEX MATCH "define *SDL_MIXER_MINOR_VERSION *([0-9]+)" _ "${header_contents}")
string(APPEND VERSION ".${CMAKE_MATCH_1}")
string(REGEX MATCH "define *SDL_MIXER_PATCHLEVEL *([0-9]+)" _ "${header_contents}")
string(APPEND VERSION ".${CMAKE_MATCH_1}")
set(SDL_VERSION 0.0)
configure_file(SDL2_mixer.pc.in "${CMAKE_CURRENT_BINARY_DIR}/SDL2_mixer.pc" @ONLY)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/SDL2_mixer.pc DESTINATION lib/pkgconfig)

if(NOT SDL_MIXER_SKIP_HEADERS)
    install(FILES SDL_mixer.h DESTINATION include/SDL2)
endif()

message(STATUS "Link-time dependencies:")
foreach(LIBRARY ${SDL_MIXER_LIBRARIES})
    message(STATUS "  " ${LIBRARY})
endforeach()
