# Don't change to vcpkg_from_github: The raw repo lacks gettext macros.
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/libconfuse/libconfuse/releases/download/v${VERSION}/confuse-${VERSION}.tar.xz"
    FILENAME "libconfuse-confuse-${VERSION}.tar.xz"
    SHA512 93cc62d98166199315f65a2f6f540a9c0d33592b69a2c6a57fd17f132aecc6ece39b9813b96c9a49ae2b66a99b7eba1188a9ce9e360e1c5fb4b973619e7088a0
)
vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

vcpkg_find_acquire_program(FLEX)
get_filename_component(FLEX_DIR "${FLEX}" DIRECTORY)
vcpkg_add_to_path("${FLEX_DIR}")

set(ENV{AUTOPOINT} true) # true, the program

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        --disable-examples
        --disable-nls
)
vcpkg_install_make()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/confuse.h" "ifdef BUILDING_STATIC" "if 1")
endif()

file(INSTALL "${CURRENT_PORT_DIR}/unofficial-libconfuse-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-libconfuse")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
