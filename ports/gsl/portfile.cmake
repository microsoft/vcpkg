set(GSL_VERSION 2.7)

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/gnu/gsl/gsl-${GSL_VERSION}.tar.gz" "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/gsl/gsl-${GSL_VERSION}.tar.gz"
    FILENAME "gsl-${GSL_VERSION}.tar.gz"
    SHA512 a14ac5400acaf4884620430dbeb6f0b28eafe946923b792ab0eccc2a2abc9113d8ce342f4b1e5396f05247649f7d6f953944a8e6bdbf9ee1adb9e67b7c3df2b5
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
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

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)