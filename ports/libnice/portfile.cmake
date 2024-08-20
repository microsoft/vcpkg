vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libnice/libnice
    REF 0.1.21
    SHA512 8808523d663da5974e81ffeef10812b758792b1f762edc1f3713d09962598a8a30d17ac1985438361d2a284b9bc82b5ba1e8d73c6e1ca86c93901bc06b634e9a
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
