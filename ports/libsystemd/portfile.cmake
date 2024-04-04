vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO systemd/systemd
  REF "v${VERSION}"
  SHA512 51728de604c2169d8643718ac72acb8f70f613cfcca9e9abb7dac519f291fa26a16d48f24cae6897356319096cfe8f4d9377743e7870127374f98d432e0c557c
  PATCHES
    disable-warning-nonnull.patch
    only-libsystemd.patch
    pkgconfig.patch
)

set(static false)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  set(static pic)
endif()

vcpkg_configure_meson(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -Dmode=release
    -Dstatic-libsystemd=${static}
    -Dtests=false
    # dependencies
    -Ddns-over-tls=false
    -Dlz4=enabled
    -Dtranslations=false
    -Dxz=enabled
    -Dzstd=enabled
  ADDITIONAL_BINARIES
    "gperf = ['${CURRENT_HOST_INSTALLED_DIR}/tools/gperf/gperf${HOST_EXECUTABLE_SUFFIX}']"
)

vcpkg_install_meson()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSES/README.md" "${SOURCE_PATH}/LICENSE.LGPL2.1"
  COMMENT [[
This port provides libsystemd.so/.a, which is based on sources in
src/basic, src/fundamental, src/systemd and src/libsystemd.
]])
