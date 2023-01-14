if(VCPKG_TARGET_IS_LINUX)
    message(STATUS "${PORT} currently requires the following libraries from the system package manager:\n    libdbus-1\n\nThese can be installed on Ubuntu systems via apt-get install libdbus-1-dev")
endif()

vcpkg_from_gitlab(
    OUT_SOURCE_PATH SOURCE_PATH
    GITLAB_URL https://gitlab.gnome.org
    REPO GNOME/at-spi2-atk
    REF AT_SPI2_ATK_2_38_0
    SHA512 d065a22e46f5d9459e14bc81050795e8b60ba8d6650ec9edf90ec6c205e68eb4ea3cc01f096cf636b066439b85892f203bc7a1c9d41f8ca899f29777556aa6cd
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dtests=false
)

vcpkg_install_meson()

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
