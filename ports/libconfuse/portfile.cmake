# Don't change to vcpkg_from_github: The raw repo lacks gettext macros.
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/libconfuse/libconfuse/releases/download/v${VERSION}/confuse-${VERSION}.tar.xz"
    FILENAME "libconfuse-confuse-${VERSION}.tar.xz"
    SHA512 3b53b8bbda339f8af479219f39a14b0772e33236b2f3cd6f2cf022b03bd8a580d2dd7595232cf0524b03a5d8884ca7481bdb33c49d15b5d0ee044af5add4011f
)
vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

vcpkg_find_acquire_program(FLEX)
get_filename_component(FLEX_DIR "${FLEX}" DIRECTORY)
vcpkg_add_to_path("${FLEX_DIR}")

set(ENV{AUTOPOINT} true) # true, the program

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    OPTIONS
        --disable-examples
        --disable-nls
)
vcpkg_make_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/confuse.h" "ifdef BUILDING_STATIC" "if 1")
endif()

file(INSTALL "${CURRENT_PORT_DIR}/unofficial-libconfuse-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-libconfuse")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
