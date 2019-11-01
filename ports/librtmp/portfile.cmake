include(vcpkg_common_functions)

set(RTMPDUMP_VERSION 2.4)
set(RTMPDUMP_FILENAME rtmpdump-${RTMPDUMP_VERSION}.tar.gz)

vcpkg_download_distfile(ARCHIVE
    URLS "http://rtmpdump.mplayerhq.hu/download/${RTMPDUMP_FILENAME}"
    FILENAME "${RTMPDUMP_FILENAME}"
    SHA512 a6253af95492739366dce620a2a6cc6f4f18d7f12f9ef2c747240259066ca135beeb02091d0f3dd8380c0c294a30d3f702ad3fad1dee1db4e70473078fb81609
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        fix_strncasecmp.patch
        hide_netstackdump.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/librtmp.def DESTINATION ${SOURCE_PATH}/librtmp)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# License and man
file(INSTALL ${SOURCE_PATH}/librtmp/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/librtmp RENAME copyright)
file(INSTALL ${SOURCE_PATH}/librtmp/librtmp.3.html DESTINATION ${CURRENT_PACKAGES_DIR}/share/librtmp)

vcpkg_copy_pdbs()
