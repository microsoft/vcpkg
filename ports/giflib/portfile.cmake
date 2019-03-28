include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(GIFLIB_VERSION 5.1.4)
vcpkg_download_distfile(ARCHIVE
    URLS "http://downloads.sourceforge.net/sourceforge/giflib/giflib-${GIFLIB_VERSION}.tar.bz2"
    FILENAME "giflib-${GIFLIB_VERSION}.tar.bz2"
    SHA512 32b5e342056c210e6478e9cb3b6ceec9594dcfaf34feea1eb4dad633a081ed4465bceee578c19165907cb47cb83912ac359ceea666a8e07dbbb5420f9928f96d
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${GIFLIB_VERSION}
    PATCHES
        msvc-guard-unistd-h.patch
        fix-compile-error.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS_DEBUG
        -DGIFLIB_SKIP_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/giflib RENAME copyright)
