set(GSL_VERSION 2.8)

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/gnu/gsl/gsl-${GSL_VERSION}.tar.gz" "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/gsl/gsl-${GSL_VERSION}.tar.gz"
    FILENAME "gsl-${GSL_VERSION}.tar.gz"
    SHA512 4427f6ce59dc14eabd6d31ef1fcac1849b4d7357faf48873aef642464ddf21cc9b500d516f08b410f02a2daa9a6ff30220f3995584b0a6ae2f73c522d1abb66b
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        0001-configure.patch
        0002-add-fp-control.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG -DINSTALL_HEADERS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)