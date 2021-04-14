vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FluidSynth/fluidsynth
    REF 2393aef3bd0b4e78084cfe16735d402bc1497edd #v2.1.4
    SHA512 181914f883982d931dfa4d8c0d0391fb91fbf3448e1eb1ea1541c938d874d7611066e7e289859d83b610a85ba089463e0a93f77db5a6253349f6b328a7373dc6
    HEAD_REF master
    PATCHES
       force-x86-gentables.patch
)

set(feature_list dbus jack libinstpatch libsndfile midishare opensles oboe oss sdl2 pulseaudio readline lash alsa systemd coreaudio coremidi dart)
set(FEATURE_OPTIONS)
foreach(_feature IN LISTS feature_list)
    list(APPEND FEATURE_OPTIONS -Denable-${_feature}:BOOL=OFF)
endforeach()

vcpkg_find_acquire_program(PKGCONFIG)
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS 
        ${FEATURE_OPTIONS}
        -DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}
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
