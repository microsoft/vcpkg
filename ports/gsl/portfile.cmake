include(vcpkg_common_functions)
set(GSL_VERSION 2.4)

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/gnu/gsl/gsl-${GSL_VERSION}.tar.gz"
    FILENAME "gsl-${GSL_VERSION}.tar.gz"
    SHA512 12442b023dd959e8b22a9c486646b5cedec7fdba0daf2604cda365cf96d10d99aefdec2b42e59c536cc071da1525373454e5ed6f4b15293b305ca9b1dc6db130
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        0001-configure.patch
        0002-add-fp-control.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG -DINSTALL_HEADERS=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
