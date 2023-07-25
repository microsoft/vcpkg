vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libnice/libnice
    REF 0.1.21
    SHA512 8808523d663da5974e81ffeef10812b758792b1f762edc1f3713d09962598a8a30d17ac1985438361d2a284b9bc82b5ba1e8d73c6e1ca86c93901bc06b634e9a
    HEAD_REF master
    PATCHES
    skip_libnice.patch
)

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dgtk_doc=disabled #Enable generating the API reference (depends on GTK-Doc)
        -Dintrospection=disabled #Enable GObject Introspection (depends on GObject)'
        -Dtests=disabled
        -Dexamples=disabled
        -Dgstreamer=enabled
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

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    # Move plugin pkg-config file
    file(COPY           "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/pkgconfig/gstnice.pc"
         DESTINATION    "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
    file(COPY           "${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/pkgconfig/gstnice.pc"
         DESTINATION    "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/pkgconfig/"
                        "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/pkgconfig/")
endif()

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(
  FILE_LIST
    "${SOURCE_PATH}/COPYING"
    "${SOURCE_PATH}/COPYING.LGPL"
    "${SOURCE_PATH}/COPYING.MPL"
)

set(USAGE_FILE "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage")
file(WRITE "${USAGE_FILE}" "${PORT} usage:\n\n")

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(APPEND "${USAGE_FILE}" "\tMake sure one of the following paths is added to the 'GST_PLUGIN_PATH' environment variable\n")
    file(APPEND "${USAGE_FILE}" "\tFor more information on GStreamer environment variables see https://gstreamer.freedesktop.org/documentation/gstreamer/running.html?gi-language=c#environment-variables\n")
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/plugins/gstreamer")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/${CMAKE_SHARED_LIBRARY_PREFIX}gstnice${CMAKE_SHARED_LIBRARY_SUFFIX}"
                    "${CURRENT_PACKAGES_DIR}/debug/plugins/gstreamer/${CMAKE_SHARED_LIBRARY_PREFIX}gstnice${CMAKE_SHARED_LIBRARY_SUFFIX}")
        if(VCPKG_TARGET_IS_WINDOWS)
            file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/gstnice.pdb"
                        "${CURRENT_PACKAGES_DIR}/debug/plugins/gstreamer/gstnice.pdb")
        else()
            file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib")
        endif()

        file(APPEND "${USAGE_FILE}" "\t\t* '<path-to-vcpkg_installed>/${TARGET_TRIPLET}/debug/plugins/gstreamer/'\n")
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/plugins/gstreamer")
        file(RENAME "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/${CMAKE_SHARED_LIBRARY_PREFIX}gstnice${CMAKE_SHARED_LIBRARY_SUFFIX}"
                    "${CURRENT_PACKAGES_DIR}/plugins/gstreamer/${CMAKE_SHARED_LIBRARY_PREFIX}gstnice${CMAKE_SHARED_LIBRARY_SUFFIX}")
        if(VCPKG_TARGET_IS_WINDOWS)
            file(RENAME "${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/gstnice.pdb"
                        "${CURRENT_PACKAGES_DIR}/plugins/gstreamer/gstnice.pdb")
        else()
            file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
        endif()

        file(APPEND "${USAGE_FILE}" "\t\t* '<path-to-vcpkg_installed>/${TARGET_TRIPLET}/plugins/gstreamer/'\n")
    endif()
else()
    file(APPEND "${USAGE_FILE}" "\tRegister static plugin with gst_plugin_register_static()\n")
    file(APPEND "${USAGE_FILE}" "\thttps://gstreamer.freedesktop.org/documentation/application-development/appendix/compiling.html#embedding-static-elements-in-your-application\n")
endif()
