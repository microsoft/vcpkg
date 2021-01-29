
vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnome.org/pub/GNOME/sources/libsigc++/2.10/libsigc++-2.10.0.tar.xz"
    FILENAME "libsigc++-2.10.0.tar.xz"
    SHA512 5b96df21d6bd6ba41520c7219e77695a86aabc60b7259262c7a9f4b8475ce0e2fd8dc37bcf7c17e24e818ff28c262d682b964c83e215b51bdbe000f3f58794ae
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS_DEBUG
        -DSIGCPP_SKIP_HEADERS=ON)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(READ ${CURRENT_PACKAGES_DIR}/include/sigc++config.h SIGCPPCONFIG_H)
    string(REPLACE "endif /* !SIGC_MSC */"
    "endif /* !SIGC_MSC */
#undef SIGC_DLL" SIGCPPCONFIG_H "${SIGCPPCONFIG_H}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/sigc++config.h "${SIGCPPCONFIG_H}")
endif()

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libsigcpp)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libsigcpp/COPYING ${CURRENT_PACKAGES_DIR}/share/libsigcpp/copyright)
