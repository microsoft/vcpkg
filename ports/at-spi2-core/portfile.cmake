if(VCPKG_TARGET_IS_LINUX)
    message(STATUS "${PORT} currently requires the following libraries from the system package manager:\n    libdbus-1-dev\n    libxi-dev\n    libxtst-dev\n\nThese can be installed on Ubuntu systems via apt-get install libdbus-1-dev libxi-dev libxtst-dev")
endif()

vcpkg_from_gitlab(
    OUT_SOURCE_PATH SOURCE_PATH
    GITLAB_URL https://gitlab.gnome.org
    REPO GNOME/at-spi2-core
    REF AT_SPI2_CORE_2_44_1
    SHA512 4e98b76e019f33af698a5e2b7ae7ce17ce0ff57784b4d505fe4bad58b097080899c1ca82b443502068c5504b60886e2d4a341bba833e0279ebef352211bf3813
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

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share" "${CURRENT_PACKAGES_DIR}/share/defaults")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
