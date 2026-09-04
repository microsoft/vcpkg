vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libnice/libnice
    REF "${VERSION}"
    SHA512 6044bcbda2a247bbaa6e5364b25cff82952ffc44d6fbc434825c0ad05935ebcb04eb08eedca9175431f01a4cff50c0c7a0aad7c287f42a9639724aba202c87a0
    HEAD_REF master
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dgtk_doc=disabled #Enable generating the API reference (depends on GTK-Doc)
        -Dintrospection=disabled #Enable GObject Introspection (depends on GObject)'
        -Dtests=disabled
        -Dexamples=disabled
        -Dgstreamer=disabled
        -Dcrypto-library=openssl
    ADDITIONAL_BINARIES glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'
                        glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
)

# Could be features:
# option('gupnp', type: 'feature', value: 'auto',
  # description: 'Enable or disable GUPnP IGD support')
# option('ignored-network-interface-prefix', type: 'array', value: ['docker', 'veth', 'virbr', 'vnet'],
  # description: 'Ignore network interfaces whose name starts with a string from this list in the ICE connection check algorithm. For example, "virbr" to ignore virtual bridge interfaces added by virtd, which do not help in finding connectivity.')
# option('crypto-library', type: 'combo', choices : ['auto', 'gnutls', 'openssl'], value : 'auto')

vcpkg_install_meson()

vcpkg_copy_pdbs()
vcpkg_copy_tools(TOOL_NAMES stunbdc stund AUTO_CLEAN)
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(
  FILE_LIST
    "${SOURCE_PATH}/COPYING"
    "${SOURCE_PATH}/COPYING.LGPL"
    "${SOURCE_PATH}/COPYING.MPL"
)
