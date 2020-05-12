set(MICROHTTPD_VERSION 0.9.63)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/gnu/libmicrohttpd/libmicrohttpd-${MICROHTTPD_VERSION}.tar.gz" "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/libmicrohttpd/libmicrohttpd-${MICROHTTPD_VERSION}.tar.gz"
    FILENAME "libmicrohttpd-${MICROHTTPD_VERSION}.tar.gz"
    SHA512 cb99e7af84fb6d7c0fd3894a9dc0fbff14959b35347506bd3211a65bbfad36455007b9e67493e97c9d8394834408df10eeabdc7758573e6aae0ba6f5f87afe17
)

vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libmicrohttpd RENAME copyright)
