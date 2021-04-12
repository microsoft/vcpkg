vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FluidSynth/fluidsynth
    REF 2393aef3bd0b4e78084cfe16735d402bc1497edd #v2.1.4
    SHA512 181914f883982d931dfa4d8c0d0391fb91fbf3448e1eb1ea1541c938d874d7611066e7e289859d83b610a85ba089463e0a93f77db5a6253349f6b328a7373dc6
    HEAD_REF master
    PATCHES
       force-x86-gentables.patch
)
vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES 
        "dbus" enable-dbus
        "jack" enable-jack
        "libinstpatch" enable-libinstpatch
        "libsndfile" enable-libsndfile
        "midishare" enable-midishare
        "opensles" enable-opensles
        "oboe" enable-oboe
        "oss" enable-oss
        "sdl2" enable-sdl2
        "pulseaudio" enable-pulseaudio
        "readline" enable-readline
    #platform dependent: 
        "lash" enable-lash
        "alsa" enable-alsa
        "systemd" enable-systemd
        "coreaudio" enable-coreaudio
        "coremidi" enable-coremidi
        "dart" enable-dart
    )
vcpkg_find_acquire_program(PKGCONFIG)
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS 
        ${FEATURE_OPTIONS}
        -DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}
        -Denable-dbus:BOOL=OFF
    OPTIONS_DEBUG
        -Denable-debug:BOOL=ON
)

vcpkg_install_cmake()

# Copy fluidsynth.exe to tools dir
vcpkg_copy_tools(TOOL_NAMES fluidsynth AUTO_CLEAN)

# Remove unnecessary files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)


# # Options disabled by default
# option ( enable-debug "enable debugging (default=no)" off )
# option ( enable-floats "enable type float instead of double for DSP samples" off )
# option ( enable-fpe-check "enable Floating Point Exception checks and debug messages" off )
# option ( enable-portaudio "compile PortAudio support" off )
# option ( enable-profiling "profile the dsp code" off )
# option ( enable-trap-on-fpe "enable SIGFPE trap on Floating Point Exceptions" off )
# option ( enable-ubsan "compile and link against UBSan (for debugging fluidsynth internals)" off )

# # Options enabled by default
# option ( enable-aufile "compile support for sound file output" on )
# option ( BUILD_SHARED_LIBS "Build a shared object or DLL" on )
# option ( enable-dbus "compile DBUS support (if it is available)" on )
# option ( enable-ipv6  "enable ipv6 support" on )
# option ( enable-jack "compile JACK support (if it is available)" on )
# option ( enable-ladspa "enable LADSPA effect units" on )
# option ( enable-libinstpatch "use libinstpatch (if available) to load DLS and GIG files" on )
# option ( enable-libsndfile "compile libsndfile support (if it is available)" on )
# option ( enable-midishare "compile MidiShare support (if it is available)" on )
# option ( enable-opensles "compile OpenSLES support (if it is available)" off )
# option ( enable-oboe "compile Oboe support (requires OpenSLES and/or AAudio)" off )
# option ( enable-network "enable network support (requires BSD sockets)" on )
# option ( enable-oss "compile OSS support (if it is available)" on )
# option ( enable-dsound "compile DirectSound support (if it is available)" on )
# option ( enable-waveout "compile Windows WaveOut support (if it is available)" on )
# option ( enable-winmidi "compile Windows MIDI support (if it is available)" on )
# option ( enable-sdl2 "compile SDL2 audio support (if it is available)" on )
# option ( enable-pkgconfig "use pkg-config to locate fluidsynth's (mostly optional) dependencies" on )
# option ( enable-pulseaudio "compile PulseAudio support (if it is available)" on )
# option ( enable-readline "compile readline lib line editing (if it is available)" on )
# option ( enable-threads "enable multi-threading support (such as parallel voice synthesis)" on )

# # Platform specific options
# if ( CMAKE_SYSTEM MATCHES "Linux|FreeBSD|DragonFly" )
    # option ( enable-lash "compile LASH support (if it is available)" on )
    # option ( enable-alsa "compile ALSA support (if it is available)" on )
# endif ( CMAKE_SYSTEM MATCHES "Linux|FreeBSD|DragonFly" )

# if ( CMAKE_SYSTEM MATCHES "Linux" )
    # option ( enable-systemd "compile systemd support (if it is available)" on )
# endif ( CMAKE_SYSTEM MATCHES "Linux" )

# if ( CMAKE_SYSTEM MATCHES "Darwin" )
    # option ( enable-coreaudio "compile CoreAudio support (if it is available)" on )
    # option ( enable-coremidi "compile CoreMIDI support (if it is available)" on )
    # option ( enable-framework "create a Mac OSX style FluidSynth.framework" on )
# endif ( CMAKE_SYSTEM MATCHES "Darwin" )

# if ( CMAKE_SYSTEM MATCHES "OS2" )
    # option ( enable-dart "compile DART support (if it is available)" on )
    # set ( enable-ipv6 off )
# endif ( CMAKE_SYSTEM MATCHES "OS2" )