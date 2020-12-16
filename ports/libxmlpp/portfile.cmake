vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(LIBXMLPP_VERSION 2.40.1)

vcpkg_download_distfile(ARCHIVE
    URLS "http://ftp.gnome.org/pub/GNOME/sources/libxml++/2.40/libxml++-${LIBXMLPP_VERSION}.tar.xz"
    FILENAME "libxml++-${LIBXMLPP_VERSION}.tar.xz"
    SHA512 a4ec2e8182d981c57bdcb8f0a203a3161f8c735ceb59fd212408b7a539d1dc826adf6717bed8f4d544ab08afd9c2fc861efe518e24bbd3a1c4b158e2ca48183a
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        fixAutoPtrExpired.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

# Handle copyright and readme
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libxmlpp RENAME copyright)
file(INSTALL ${SOURCE_PATH}/README DESTINATION ${CURRENT_PACKAGES_DIR}/share/libxmlpp)
