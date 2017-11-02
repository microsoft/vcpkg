include(vcpkg_common_functions)

set(RTMPDUMP_VERSION 2.3)
set(RTMPDUMP_FILENAME rtmpdump-${RTMPDUMP_VERSION}.tgz)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/rtmpdump-${RTMPDUMP_VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "http://rtmpdump.mplayerhq.hu/download/${RTMPDUMP_FILENAME}"
    FILENAME "${RTMPDUMP_FILENAME}"
    SHA512 d8240ba372a704231286b81bbf75716d8b76874840538c4e1527f7f8b6ca66eeaba6b03167fe6fab06bf80f20f07d89ecb84cc428b3196234174a43f3328ec2a
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/librtmp.def DESTINATION ${SOURCE_PATH}/librtmp)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/fix_strncasecmp.patch
        ${CMAKE_CURRENT_LIST_DIR}/hide_netstackdump.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# License and man
file(INSTALL ${SOURCE_PATH}/librtmp/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/librtmp RENAME copyright)
file(INSTALL ${SOURCE_PATH}/librtmp/librtmp.3.html DESTINATION ${CURRENT_PACKAGES_DIR}/share/librtmp)

vcpkg_copy_pdbs()
