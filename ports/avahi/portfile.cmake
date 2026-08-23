vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO avahi/avahi
  REF "v${VERSION}"
  SHA512 27bba9a551152dfc7e721f326042e7bfce55d227044a6cbaee04d6fb0e3f59c36e159c2b7a4dd42d1c955cdf37cc1c303e91991c08928bbded91d796e9a22abe
  HEAD_REF master
  PATCHES
    # This patch will be part of v0.9
    pc-libevent-requires.diff
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    client  ENABLE_DBUS
)

vcpkg_list(SET options
  "--disable-qt3"
  "--disable-qt4"
  "--disable-gtk"
  "--disable-gtk3"
  "--disable-python"
  "--disable-mono"
  "--disable-monodoc"
  "--disable-autoipd"
  "--disable-manpages"
  "--enable-core-docs=no"
  "--enable-tests=no"
)

if(NOT ${ENABLE_DBUS})
  list(APPEND options "--disable-dbus")
endif()

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    COPY_SOURCE
    OPTIONS
      ${options}
)

vcpkg_make_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
  "${CURRENT_PACKAGES_DIR}/debug/etc"
  "${CURRENT_PACKAGES_DIR}/debug/share"
  "${CURRENT_PACKAGES_DIR}/debug/lib/avahi"

  "${CURRENT_PACKAGES_DIR}/etc"
  "${CURRENT_PACKAGES_DIR}/tools"

  # Empty dir the libraries are installed in the lib directory itself
  "${CURRENT_PACKAGES_DIR}/lib/avahi"

  # Unneeded directories for the actual libraries
  "${CURRENT_PACKAGES_DIR}/share/avahi/avahi"
  "${CURRENT_PACKAGES_DIR}/share/avahi/dbus-1"
  "${CURRENT_PACKAGES_DIR}/share/avahi/man1"
  "${CURRENT_PACKAGES_DIR}/share/avahi/locale"
)
