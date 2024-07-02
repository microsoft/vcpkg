vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO systemd/systemd
  REF "v${VERSION}"
  SHA512 5441f634f43b726c13fe57d1ba0030f1b91427d7c2d4f4f32e4add8ff93aeb5139e9337422653df3b897c241e0a8760dafcd441dc622d1e2c1230bbe27dd1a1c
  PATCHES
    disable-warning-nonnull.patch
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
    # disabled capabilites
    -Ddns-over-tls=false
    -Dtranslations=false
    # disabled dependencies
    -Dacl=disabled
    -Dapparmor=disabled
    -Daudit=disabled
    -Dblkid=disabled
    -Dbpf-framework=disabled
    -Dbzip2=disabled
    -Ddbus=disabled # tests only
    -Delfutils=disabled
    -Dfdisk=disabled
    -Dgcrypt=disabled
    -Dglib=disabled # tests only
    -Dgnutls=disabled
    -Dkmod=disabled
    -Dlibcurl=disabled
    -Dlibcryptsetup=disabled
    -Dlibfido2=disabled
    -Dlibidn=disabled
    -Dlibidn2=disabled
    -Dlibiptc=disabled
    -Dmicrohttpd=disabled
    -Dopenssl=disabled
    -Dp11kit=disabled
    -Dpam=disabled
    -Dpcre2=disabled
    -Dpolkit=disabled
    -Dpwquality=disabled
    -Dpasswdqc=disabled
    -Dseccomp=disabled
    -Dselinux=disabled
    -Dtpm2=disabled
    -Dxenctrl=disabled
    -Dxkbcommon=disabled
    -Dzlib=disabled
    # enabled dependencies
    -Dlz4=enabled
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
