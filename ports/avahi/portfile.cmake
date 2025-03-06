vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO avahi/avahi
  REF "v${VERSION}"
  SHA512 61f656da7614d8cca1862180038f571db3474c84f05db4d3509f614cdbf8b1a1047661b7e24d63682d5b48ed1bfa1b08b3c9e6dbe9222bcd62d99bc168a11abe
  HEAD_REF master
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
