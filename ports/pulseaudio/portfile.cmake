vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pulseaudio/pulseaudio
    REF "v${VERSION}"
    SHA512  84b5218dca3a6f793eec5427606a09cabcf108a2aad8316c15422c130d76d1ed6de14e93549c6d952e4f33bcd1e7621d30ebaa145986a5e6fc890e0655c00e07
    HEAD_REF master
)

file(WRITE "${SOURCE_PATH}/.tarball-version" "${VERSION}")
file(REMOVE "${SOURCE_PATH}/git-version-gen")
vcpkg_replace_string ("${SOURCE_PATH}/meson.build"
  "run_command(find_program('git-version-gen'), join_paths(meson.current_source_dir(), '.tarball-version'), check : false).stdout().strip()" 
  "'${VERSION}'")

set(opts "")
if(VCPKG_TARGET_IS_LINUX)
  list(APPEND opts
    -Dalsa=enabled
    -Doss-output=enabled
  )
else()
  list(APPEND opts
    -Dalsa=disabled
    -Doss-output=disabled
  )
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
      
      -Dasyncns=disabled # requires port?
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
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/PulseAudio")

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/bin/padsp" "${CURRENT_PACKAGES_DIR}" [[$(dirname "$0")/../..]])
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/etc/pulse/client.conf" "${CURRENT_PACKAGES_DIR}" "<path-to-pulseaudio>")
if(NOT VCPKG_BUILD_TYPE)
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/etc/pulse/client.conf" "${CURRENT_PACKAGES_DIR}" "<path-to-pulseaudio>")
endif()
vcpkg_copy_tools(TOOL_NAMES pacat pactl padsp pa-info pamon AUTO_CLEAN)

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
