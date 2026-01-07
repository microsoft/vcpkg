if(VCPKG_TARGET_IS_LINUX)
    message(STATUS "${PORT} currently requires the following libraries from the system package manager:\n    libxi-dev\n    libxtst-dev\n\nThese can be installed on Ubuntu systems via apt-get install libxi-dev libxtst-dev")
endif()

string(REGEX MATCH [[^[0-9][0-9]*\.[1-9][0-9]*]] VERSION_MAJOR_MINOR ${VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS
        "https://download.gnome.org/sources/${PORT}/${VERSION_MAJOR_MINOR}/${PORT}-${VERSION}.tar.xz"
        "https://www.mirrorservice.org/sites/ftp.gnome.org/pub/GNOME/sources/${PORT}/${VERSION_MAJOR_MINOR}/${PORT}-${VERSION}.tar.xz"
    FILENAME "GNOME-${PORT}-${VERSION}.tar.xz"
    SHA512 46bed060b61e62d0e53047bb59741367cf5e4a79ff4aa4486c62ca282aacd0d9d77f6f711bac3b9215fc120126685b9c6fdfea451841bcefbf0665b9c742da6b
)

vcpkg_extract_source_archive(SOURCE_PATH ARCHIVE "${ARCHIVE}")

if("introspection" IN_LIST FEATURES)
    list(APPEND OPTIONS_RELEASE -Dintrospection=enabled)
    vcpkg_get_gobject_introspection_programs(PYTHON3 GIR_COMPILER GIR_SCANNER)
else()
    list(APPEND OPTIONS_RELEASE -Dintrospection=disabled)
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_RELEASE
        ${OPTIONS_RELEASE}
    OPTIONS_DEBUG
        -Dintrospection=disabled
    ADDITIONAL_BINARIES
        glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'
        glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
        "g-ir-compiler='${GIR_COMPILER}'"
        "g-ir-scanner='${GIR_SCANNER}'"
)

vcpkg_install_meson()

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/atspi-2.pc"
        "-DG_LOG_DOMAIN=\"dbind\"" ""
    )
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/atspi-2.pc"
        "-DG_LOG_DOMAIN=\"dbind\"" ""
    )
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share" "${CURRENT_PACKAGES_DIR}/share/defaults")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
