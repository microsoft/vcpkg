vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO avahi/avahi
    REF "v${VERSION}"
    SHA512 8afe102be275b9714a920c5bd31ea7e317c54574385ff38cac8ffbb9bf5cbdd0110a2df8439aefdffb4711c257f86494517b1dd27da3a5d5ff623808634b523d
    HEAD_REF master
    PATCHES
        backport-service-name-join.patch # https://github.com/avahi/avahi/commit/333c6f457e9e67f4f688b497cac25689be83b5c2
        fix-static-pkgconfig.patch
)

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    OPTIONS
        --with-distro=none
        --with-xml=none
        --with-dbus-system-address=unix:path=/var/run/dbus/system_bus_socket
        --disable-nls
        --disable-libdaemon
        --disable-autoipd
        --disable-libsystemd
        --disable-gdbm
        --disable-glib
        --disable-gobject
        --disable-libevent
        --disable-qt3
        --disable-qt4
        --disable-qt5
        --disable-gtk
        --disable-gtk3
        --disable-python
        --disable-pygobject
        --disable-python-dbus
        --disable-mono
        --disable-monodoc
        --disable-compat-libdns_sd
        --disable-compat-howl
        --disable-manpages
        --disable-xmltoman
        --disable-doxygen-doc
        --disable-tests
)
vcpkg_make_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/var"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/man1"
    "${CURRENT_PACKAGES_DIR}/tools"
    "${CURRENT_PACKAGES_DIR}/var"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
