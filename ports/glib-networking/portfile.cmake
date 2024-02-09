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
        libproxy libproxy
        environment-proxy environment_proxy
)

string(REPLACE "OFF" "disabled" FEATURE_OPTIONS "${FEATURE_OPTIONS}")
string(REPLACE "ON" "enabled" FEATURE_OPTIONS "${FEATURE_OPTIONS}")

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dgnutls=disabled # I can't install it on centos 7 with vcpkg, so always openssl instead.
        -Dopenssl=enabled
        ${FEATURE_OPTIONS}
        -Dgnome_proxy=disabled
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

#make vcpkg post-build happy
file(COPY "${CMAKE_CURRENT_LIST_DIR}/placeholder.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/glib-networking")
file(GLOB MODULE_FILES "${CURRENT_PACKAGES_DIR}/lib/gio/modules/*")
file(COPY ${MODULE_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/plugins/${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(GLOB MODULE_DEBUG_FILES "${CURRENT_PACKAGES_DIR}/debug/lib/gio/modules/*")
file(COPY ${MODULE_DEBUG_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/plugins/${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")