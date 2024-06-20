if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

# Keep distfile, don't use GitLab!
string(REGEX MATCH "^([0-9]*[.][0-9]*)" ATKMM_MAJOR_MINOR "${VERSION}")
vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnome.org/pub/GNOME/sources/atkmm/${ATKMM_MAJOR_MINOR}/atkmm-${VERSION}.tar.xz"
    FILENAME "atkmm-${VERSION}.tar.xz"
    SHA512 2c2513b5c5fd7a5c9392727325c7551c766d4d51b8089fbea7e8043cde97d07c9b1f98a4a693f30835e4366e9236e28e092c2480a78415d77c5cb72e9432344f
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dbuild-documentation=false
        -Dbuild-deprecated-api=true # Build deprecated API and include it in the library
        -Dmsvc14x-parallel-installable=false # Use separate DLL and LIB filenames for Visual Studio 2017 and 2019
)
vcpkg_install_meson()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${SOURCE_PATH}/README.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME readme.txt)
file(INSTALL "${SOURCE_PATH}/README.win32.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
