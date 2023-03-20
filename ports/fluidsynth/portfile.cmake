vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FluidSynth/fluidsynth
    REF "v${VERSION}"
    SHA512 1633294bf6c714361c381151b62d9dd2c8f388490153e7964bfa14fd647a681db9ebfe1de0a06279972d6c5b30377f67361feb4db186b1faa235600f0ae02b22
    HEAD_REF master
    PATCHES
        gentables.patch
        add-usage-requirements.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        buildtools  VCPKG_BUILD_MAKE_TABLES
        sndfile     enable-libsndfile
)

set(feature_list dbus jack libinstpatch midishare opensles oboe openmp oss sdl2 pulseaudio readline lash systemd dart)
foreach(_feature IN LISTS feature_list)
    list(APPEND FEATURE_OPTIONS -Denable-${_feature}:BOOL=OFF)
endforeach()

# enable platform-specific features, and force the build to fail if the
# required libraries are not found
list(APPEND FEATURE_OPTIONS -Denable-dsound=${VCPKG_TARGET_IS_WINDOWS})
list(APPEND FEATURE_OPTIONS -Denable-wasapi=${VCPKG_TARGET_IS_WINDOWS})
list(APPEND FEATURE_OPTIONS -Denable-waveout=${VCPKG_TARGET_IS_WINDOWS})
list(APPEND FEATURE_OPTIONS -Denable-winmidi=${VCPKG_TARGET_IS_WINDOWS})
list(APPEND FEATURE_OPTIONS -DHAVE_MMSYSTEM_H=${VCPKG_TARGET_IS_WINDOWS})
list(APPEND FEATURE_OPTIONS -DHAVE_DSOUND_H=${VCPKG_TARGET_IS_WINDOWS})
list(APPEND FEATURE_OPTIONS -DHAVE_WASAPI_HEADERS=${VCPKG_TARGET_IS_WINDOWS})
list(APPEND FEATURE_OPTIONS -DHAVE_OBJBASE_H=${VCPKG_TARGET_IS_WINDOWS})
list(APPEND FEATURE_OPTIONS -Denable-coreaudio=${VCPKG_TARGET_IS_OSX})
list(APPEND FEATURE_OPTIONS -Denable-coremidi=${VCPKG_TARGET_IS_OSX})
list(APPEND FEATURE_OPTIONS -DCOREAUDIO_FOUND=${VCPKG_TARGET_IS_OSX})
list(APPEND FEATURE_OPTIONS -DCOREMIDI_FOUND=${VCPKG_TARGET_IS_OSX})
list(APPEND FEATURE_OPTIONS -Denable-alsa=${VCPKG_TARGET_IS_LINUX})
list(APPEND FEATURE_OPTIONS -DALSA_FOUND=${VCPKG_TARGET_IS_LINUX})

vcpkg_find_acquire_program(PKGCONFIG)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DVCPKG_HOST_TRIPLET=${HOST_TRIPLET}"
        ${FEATURE_OPTIONS}
        -DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}
        -Denable-framework=OFF # Needs system permission to install framework
    MAYBE_UNUSED_VARIABLES
        enable-coreaudio
        enable-coremidi
        enable-dart
        ALSA_FOUND
        COREAUDIO_FOUND
        COREMIDI_FOUND
        VCPKG_BUILD_MAKE_TABLES
        enable-framework
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/fluidsynth)

vcpkg_fixup_pkgconfig()

set(tools fluidsynth)
if("buildtools" IN_LIST FEATURES)
    list(APPEND tools make_tables)
endif()
vcpkg_copy_tools(TOOL_NAMES ${tools} AUTO_CLEAN)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/man")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
