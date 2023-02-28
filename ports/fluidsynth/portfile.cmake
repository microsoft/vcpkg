vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FluidSynth/fluidsynth
    REF v2.2.8
    SHA512 8173f2d368a214cf1eb7faae2f6326db43fb094ec9c83e652f953290c3f29c34ebd0b92cbb439bea8d814d3a7e4f9dc0c18c648df1d414989d5d8b4700c79535
    HEAD_REF master
    PATCHES
        fix-dependencies.patch
        gentables.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        buildtools  VCPKG_BUILD_MAKE_TABLES
        sndfile     enable-libsndfile
)

set(feature_list dbus jack libinstpatch midishare opensles oboe oss sdl2 pulseaudio readline lash systemd dart)
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
        -DLIB_INSTALL_DIR=lib
        -Denable-pkgconfig=ON
        -Denable-framework=OFF # Needs system permission to install framework
    OPTIONS_DEBUG
        -Denable-debug:BOOL=ON
    MAYBE_UNUSED_VARIABLES
        enable-coreaudio
        enable-coremidi
        enable-dart
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

set(tools fluidsynth)
if("buildtools" IN_LIST FEATURES)
    list(APPEND tools make_tables)
endif()
vcpkg_copy_tools(TOOL_NAMES ${tools} AUTO_CLEAN)

# Remove unnecessary files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
