if(VCPKG_TARGET_IS_LINUX)
    message(STATUS "${PORT} currently requires the following libraries from the system package manager:\n    libxi-dev\n    libxtst-dev\n\nThese can be installed on Ubuntu systems via apt-get install libxi-dev libxtst-dev")
endif()

string(REPLACE "." "_" UNDERSCORES_VERSION "${VERSION}")

vcpkg_from_gitlab(
    OUT_SOURCE_PATH SOURCE_PATH
    GITLAB_URL https://gitlab.gnome.org
    REPO GNOME/at-spi2-core
    REF "AT_SPI2_CORE_${UNDERSCORES_VERSION}"
    SHA512 7b2b6abe5e90b1cdaa2c752da224657e09cb178ed174542815d1a528254727278fdd2b8218a1a0a68632966f851f65b5774d973a3e1f8c1f9e96c802ec40d76f
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dintrospection=no
    ADDITIONAL_BINARIES
        glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'
        glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
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
