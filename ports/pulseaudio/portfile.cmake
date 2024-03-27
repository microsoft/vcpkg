vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pulseaudio/pulseaudio
    REF "v${VERSION}"
    SHA512  84b5218dca3a6f793eec5427606a09cabcf108a2aad8316c15422c130d76d1ed6de14e93549c6d952e4f33bcd1e7621d30ebaa145986a5e6fc890e0655c00e07
    HEAD_REF master
    PATCHES
      fix-build.patch
)

file(WRITE "${SOURCE_PATH}/.tarball-version" "${VERSION}")
file(REMOVE "${SOURCE_PATH}/git-version-gen")
vcpkg_replace_string ("${SOURCE_PATH}/meson.build"
  "run_command(find_program('git-version-gen'), join_paths(meson.current_source_dir(), '.tarball-version'), check : false).stdout().strip()" 
  "'${VERSION}'")

set(opts "")
if(VCPKG_TARGET_IS_LINUX)
  set(opts
    -Dalsa=enabled
    -Doss-output=enabled
  )
else()
  set(opts
    -Dalsa=disabled
    -Doss-output=disabled
  )
endif()

if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_acquire_msys(MSYS_ROOT PACKAGES m4)
  vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      ${opts}
      -Ddaemon=false
      -Dclient=true
      -Ddoxygen=false
      -Dgcov=false
      -Dman=false
      -Dtests=false
      -Dbashcompletiondir=no
      -Dzshcompletiondir=no
      
      -Dasyncns=disabled # rerquires port?
      -Davahi=disabled
      -Dbluez5=disabled
      -Dbluez5-native-headset=false
      -Dbluez5-ofono-headset=false
      -Dconsolekit=disabled
      -Ddbus=enabled
      -Delogind=disabled
      -Dfftw=enabled
      -Dglib=enabled
      -Dgsettings=disabled
      -Dgstreamer=enabled
      -Dgtk=disabled
      -Dhal-compat=false
      -Dipv6=true
      -Dopenssl=enabled
      -Djack=enabled # jack2?
      -Dlirc=enabled # does this need a port?
      -Dorc=enabled # does this need a port? "orc" ?

      -Dsoxr=enabled
      -Dspeex=enabled
      -Dsystemd=disabled
      -Dtcpwrap=enabled # dito
      -Dudev=disabled # port ?
      -Dvalgrind=disabled
      -Dx11=disabled
      
      -Dadrian-aec=false
      -Dwebrtc-aec=disabled
)


vcpkg_replace_string("${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/config.h" "${CURRENT_PACKAGES_DIR}" "~~invalid~~")
vcpkg_replace_string("${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/config.h" "${SOURCE_PATH}" "~~invalid~~")
if(NOT VCPKG_BUILD_TYPE)
  vcpkg_replace_string("${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/config.h" "${CURRENT_PACKAGES_DIR}/debug" "~~invalid~~")
  vcpkg_replace_string("${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/config.h" "${SOURCE_PATH}" "~~invalid~~")
endif()

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(PACKAGE_NAME PulseAudio CONFIG_PATH "lib/cmake/PulseAudio")

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/bin/padsp" "${CURRENT_PACKAGES_DIR}" "$(dirname "$0")/../..")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/etc/pulse/client.conf" "${CURRENT_PACKAGES_DIR}" "<path-to-pulseaudio>")
if(NOT VCPKG_BUILD_TYPE)
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/etc/pulse/client.conf" "${CURRENT_PACKAGES_DIR}" "<path-to-pulseaudio>")
endif()
vcpkg_copy_tools(TOOL_NAMES pacat pactl padsp pa-info pamon AUTO_CLEAN)

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

#define DESKTOPFILEDIR "/mnt/e/qt6-update/packages/pulseaudio_x64-linux-release/share/applications"
#define PA_ALSA_DATA_DIR "/mnt/e/qt6-update/packages/pulseaudio_x64-linux-release/share/pulseaudio/alsa-mixer"
#define PA_BINARY "/mnt/e/qt6-update/packages/pulseaudio_x64-linux-release/bin/pulseaudio"
#define PA_BUILDDIR "/mnt/e/qt6-update/buildtrees/pulseaudio/x64-linux-release-rel"
#define PA_CFLAGS "Not yet supported on meson"
#define PA_DEFAULT_CONFIG_DIR "/mnt/e/qt6-update/packages/pulseaudio_x64-linux-release/etc/pulse"
#define PA_DEFAULT_CONFIG_DIR_UNQUOTED /mnt/e/qt6-update/packages/pulseaudio_x64-linux-release/etc/pulse
#define PA_DLSEARCHPATH "/mnt/e/qt6-update/packages/pulseaudio_x64-linux-release/lib/pulseaudio/modules"
#define PA_INCDIR /mnt/e/qt6-update/packages/pulseaudio_x64-linux-release/include
#define PA_LIBDIR /mnt/e/qt6-update/packages/pulseaudio_x64-linux-release/lib
#define PA_MACHINE_ID "/mnt/e/qt6-update/packages/pulseaudio_x64-linux-release/etc/machine-id"
#define PA_MACHINE_ID_FALLBACK "/mnt/e/qt6-update/packages/pulseaudio_x64-linux-release/var/lib/dbus/machine-id"
#define PA_MAJOR 17
#define PA_MINOR 0
#define PA_PROTOCOL_VERSION 35
#define PA_SOEXT ".so"
#define PA_SRCDIR "/mnt/e/qt6-update/buildtrees/pulseaudio/src/v17.0-bdc7dd31a8.clean/src"
#define PA_SYSTEM_CONFIG_PATH "/mnt/e/qt6-update/packages/pulseaudio_x64-linux-release/var/lib/pulse"
#define PA_SYSTEM_GROUP "pulse"
#define c "/mnt/e/qt6-update/packages/pulseaudio_x64-linux-release/var/run/pulse"
#define PA_SYSTEM_STATE_PATH "/mnt/e/qt6-update/packages/pulseaudio_x64-linux-release/var/lib/pulse"
#define PA_SYSTEM_USER "pulse"
#define PULSEDSP_LOCATION /mnt/e/qt6-update/packages/pulseaudio_x64-linux-release/lib/pulseaudio
#define PULSE_LOCALEDIR "/mnt/e/qt6-update/packages/pulseaudio_x64-linux-release/share/locale"
#define top_srcdir /mnt/e/qt6-update/buildtrees/pulseaudio/src/v17.0-bdc7dd31a8.clean