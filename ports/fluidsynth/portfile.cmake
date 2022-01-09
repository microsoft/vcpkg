vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FluidSynth/fluidsynth
    REF 6c807bdd37748411801e93c48fcd5789d5a6a278 #v2.2.4
    SHA512 5fab3b4d58fa47825cf6afc816828fb57879523b8d7659fb20deacdf5439e74fd4b0f2b3f03a8db89cc4106b3b36f2ec450a858e02af30245b6413db70060a11
    HEAD_REF master
    PATCHES
        fix-dependencies.patch
        separate-gentables.patch
)

if ("buildtools" IN_LIST FEATURES)
    vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}/src/gentables"
        LOGFILE_BASE configure-tools
    )

    vcpkg_cmake_build(
        LOGFILE_BASE install-tools
        TARGET install
    )

    vcpkg_copy_tools(TOOL_NAMES make_tables AUTO_CLEAN)

    vcpkg_add_to_path(APPEND "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
endif()

set(feature_list dbus jack libinstpatch libsndfile midishare opensles oboe oss sdl2 pulseaudio readline lash alsa systemd coreaudio coremidi dart)
vcpkg_list(SET FEATURE_OPTIONS)
foreach(_feature IN LISTS feature_list)
    list(APPEND FEATURE_OPTIONS -Denable-${_feature}:BOOL=OFF)
endforeach()

vcpkg_add_to_path("${CURRENT_HOST_INSTALLED_DIR}/tools/${PORT}")

vcpkg_find_acquire_program(PKGCONFIG)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
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

# Copy fluidsynth.exe to tools dir
vcpkg_copy_tools(TOOL_NAMES fluidsynth AUTO_CLEAN)

# Remove unnecessary files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
