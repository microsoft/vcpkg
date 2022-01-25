set(GSL_VERSION 2.7.1)

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/gnu/gsl/gsl-${GSL_VERSION}.tar.gz" "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/gsl/gsl-${GSL_VERSION}.tar.gz"
    FILENAME "gsl-${GSL_VERSION}.tar.gz"
    SHA512 3300a748b63b583374701d5ae2a9db7349d0de51061a9f98e7c145b2f7de9710b3ad58b3318d0be2a9a287ace4cc5735bb9348cdf48075b98c1f6cc1029df131
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