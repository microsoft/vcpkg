set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

string(REGEX MATCH [[^[0-9][0-9]*\.[1-9][0-9]*]] VERSION_MAJOR_MINOR "${VERSION}")
vcpkg_download_distfile(ARCHIVE
    URLS
        "https://download.gnome.org/sources/${PORT}/${VERSION_MAJOR_MINOR}/${PORT}-${VERSION}.tar.xz"
        "https://www.mirrorservice.org/sites/ftp.gnome.org/pub/GNOME/sources/${PORT}/${VERSION_MAJOR_MINOR}/${PORT}-${VERSION}.tar.xz"
    FILENAME "GNOME-${PORT}-${VERSION}.tar.xz"
    SHA512 0f1b3807635fcae143ad1a89731a8f7e1b6f4b8f6cc2dd1b7b5eea3d77c796ee5a55ea330901bfd22927d07795f39450d30f0f1029595761e659f96a8415c263
)

vcpkg_extract_source_archive(SOURCE_PATH ARCHIVE "${ARCHIVE}")

vcpkg_list(SET FEATURE_OPTIONS)
if (gnutls IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -Dgnutls=enabled)
else()
    list(APPEND FEATURE_OPTIONS -Dgnutls=disabled)
endif()

if (openssl IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -Dopenssl=enabled)
else()
    list(APPEND FEATURE_OPTIONS -Dopenssl=disabled)
endif()

if (libproxy IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -Dlibproxy=enabled)
else()
    list(APPEND FEATURE_OPTIONS -Dlibproxy=disabled)
endif()

if (environment-proxy IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -Denvironment_proxy=enabled)
else()
    list(APPEND FEATURE_OPTIONS -Denvironment_proxy=disabled)
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -Dgnome_proxy=disabled
    ADDITIONAL_BINARIES
        "gio-querymodules = '${CURRENT_HOST_INSTALLED_DIR}/tools/glib/gio-querymodules${CMAKE_EXECUTABLE_SUFFIX}'"
)

vcpkg_install_meson()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/gio/modules/pkgconfig")
file(GLOB MODULE_FILES "${CURRENT_PACKAGES_DIR}/lib/gio/modules/*")
file(COPY ${MODULE_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/plugins/${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/gio/modules/pkgconfig")
file(GLOB MODULE_DEBUG_FILES "${CURRENT_PACKAGES_DIR}/debug/lib/gio/modules/*")
file(COPY ${MODULE_DEBUG_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/plugins/${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib")

if(libproxy IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES glib-pacrunner SEARCH_DIR "${CURRENT_PACKAGES_DIR}/libexec")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/libexec" "${CURRENT_PACKAGES_DIR}/debug/libexec")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/dbus-1/services/org.gtk.GLib.PACRunner.service" "${CURRENT_PACKAGES_DIR}/libexec/glib-pacrunner" "${CURRENT_HOST_INSTALLED_DIR}/tools/${PORT}/glib-pacrunner")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
