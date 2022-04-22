vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fadingred/libgpod
    REF 4a8a33ef4bc58eee1baca6793618365f75a5c3fa
    SHA512 b7a120c1106c1205e8de2808de5ac4ff1cf189943017939a5ea4eded4e1ceef44557587e69a8591cc5249f8c8dbf0cbdcce1dd309d33a0e9207b0560abe3ae39
    HEAD_REF master
    PATCHES configure.ac.patch
)

vcpkg_execute_required_process(
    COMMAND intltoolize --force --copy --automake
    WORKING_DIRECTORY "${SOURCE_PATH}"
    LOGNAME intltoolize-${TARGET_TRIPLET}
)
vcpkg_execute_required_process(
    COMMAND gtkdocize --copy
    WORKING_DIRECTORY "${SOURCE_PATH}"
    LOGNAME gtkdocize-${TARGET_TRIPLET}
)
vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
    OPTIONS
        --without-hal
        --disable-gdk-pixbuf
        --disable-pygobject
        --disable-more-warnings
        --disable-libxml
        --disable-gtk-doc-html
)
vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/README DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
