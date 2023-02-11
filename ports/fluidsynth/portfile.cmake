vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FluidSynth/fluidsynth
    REF "v${VERSION}"
    SHA512 1633294bf6c714361c381151b62d9dd2c8f388490153e7964bfa14fd647a681db9ebfe1de0a06279972d6c5b30377f67361feb4db186b1faa235600f0ae02b22
    HEAD_REF master
    PATCHES
        gentables.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        buildtools  VCPKG_BUILD_MAKE_TABLES
        sndfile     enable-libsndfile
)

# enable platform-specific features, and force the build to fail if the
# required libraries are not found
set(WINDOWS_FEATURES "enable-dsound" "enable-wasapi" "enable-waveout" "enable-winmidi" "HAVE_MMSYSTEM_H" "HAVE_DSOUND_H" "HAVE_WASAPI_HEADERS" "HAVE_OBJBASE_H")
set(MACOS_FEATURES "enable-coreaudio" "enable-coremidi" "COREAUDIO_FOUND" "COREMIDI_FOUND")
set(LINUX_FEATURES "enable-alsa" "ALSA_FOUND")
set(DISABLED_FEATURES "enable-dbus" "enable-pipewire" "enable-jack" "enable-libinstpatch" "enable-midishare" "enable-opensles" "enable-oboe" "enable-oss" "enable-sdl2" "enable-pulseaudio" "enable-readline" "enable-lash" "enable-systemd" "enable-dart" "enable-framework")

if(VCPKG_TARGET_IS_WINDOWS)
    set(ENABLED_FEATURES "${WINDOWS_FEATURES}")
    list(APPEND DISABLED_FEATURES "${MACOS_FEATURES}" "${LINUX_FEATURES}")
elseif(VCPKG_TARGET_IS_OSX)
    set(ENABLED_FEATURES "${MACOS_FEATURES}")
    list(APPEND DISABLED_FEATURES "${WINDOWS_FEATURES}" "${LINUX_FEATURES}")
elseif(VCPKG_TARGET_IS_LINUX)
    set(ENABLED_FEATURES "${LINUX_FEATURES}")
    list(APPEND DISABLED_FEATURES "${WINDOWS_FEATURES}" "${MACOS_FEATURES}")
endif()

foreach(FEATURE IN LISTS ENABLED_FEATURES)
    list(APPEND FEATURE_OPTIONS "-D${FEATURE}:BOOL=ON")
endforeach()

foreach(FEATURE IN LISTS DISABLED_FEATURES)
    list(APPEND FEATURE_OPTIONS "-D${FEATURE}:BOOL=OFF")
endforeach()

vcpkg_find_acquire_program(PKGCONFIG)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DVCPKG_HOST_TRIPLET=${HOST_TRIPLET}"
        ${FEATURE_OPTIONS}
        -DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}
    MAYBE_UNUSED_VARIABLES
        ${DISABLED_FEATURES}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/fluidsynth")
vcpkg_fixup_pkgconfig()

set(TOOLS fluidsynth)
if("buildtools" IN_LIST FEATURES)
    list(APPEND TOOLS make_tables)
endif()
vcpkg_copy_tools(TOOL_NAMES ${TOOLS} AUTO_CLEAN)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/debug/include" 
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/man")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
