set(VCPKG_POLICY_DLLS_WITHOUT_EXPORTS enabled)
vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.gnome.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GNOME/glib-networking
    REF "${VERSION}"
    SHA512 "35b6b05afab29da4f4d54f559ded3cc6a16376f188afdb72689b7d9bcba71b9963317bcbd1101327137ae31ee51e25438f9bfa267e23d6076706a64c3594cbb5"
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        gnutls gnutls
        openssl openssl
        libproxy libproxy
        environment-proxy environment_proxy
)

string(REPLACE "OFF" "disabled" FEATURE_OPTIONS "${FEATURE_OPTIONS}")
string(REPLACE "ON" "enabled" FEATURE_OPTIONS "${FEATURE_OPTIONS}")

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -Dgnome_proxy=disabled
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

# file(GLOB_RECURSE MY_DLLS "${CURRENT_PACKAGES_DIR}/lib/*.dll")
# file(COPY ${MY_DLLS} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
# file(GLOB_RECURSE MY_DEBUG_DLLS "${CURRENT_PACKAGES_DIR}/debug/lib/*.dll")
# file(COPY ${MY_DEBUG_DLLS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
# vcpkg_copy_pdbs()
# file(GLOB_RECURSE MY_LIBS "${CURRENT_PACKAGES_DIR}/lib/*.lib")
# file(COPY ${MY_LIBS} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
# file(GLOB_RECURSE MY_DEBUG_LIBS "${CURRENT_PACKAGES_DIR}/debug/lib/*.lib")
# file(COPY ${MY_DEBUG_LIBS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
# file(COPY "${CURRENT_PACKAGES_DIR}/lib/gio/modules/giomodule.cache" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
# file(COPY "${CURRENT_PACKAGES_DIR}/debug/lib/gio/modules/giomodule.cache" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
# file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/gio")
# file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/gio")
# vcpkg_copy_tools(TOOL_NAMES glib-pacrunner SEARCH_DIR ${CURRENT_PACKAGES_DIR}/libexec AUTO_CLEAN)
# vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")
file(COPY "${CURRENT_PACKAGES_DIR}/lib/gio/modules" DESTINATION "${CURRENT_PACKAGES_DIR}/plugins/${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/gio")
file(COPY "${CURRENT_PACKAGES_DIR}/debug/lib/gio/modules" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/plugins/${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/gio")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")