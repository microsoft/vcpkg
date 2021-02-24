vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(JBIGKIT_VERSION 2.1)
set(JBIGKIT_HASH c4127480470ef90db1ef3bd2caa444df10b50ed8df0bc9997db7612cb48b49278baf44965028f1807a21028eb965d677e015466306b44683c4ec75a23e1922cf)

vcpkg_download_distfile(ARCHIVE
    URLS "http://www.cl.cam.ac.uk/~mgk25/jbigkit/download/jbigkit-${JBIGKIT_VERSION}.tar.gz"
    FILENAME "jbigkit-${JBIGKIT_VERSION}.tar.gz"
    SHA512 ${JBIGKIT_HASH}
)

vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/jbigkit)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/jbigkit/COPYING ${CURRENT_PACKAGES_DIR}/share/jbigkit/copyright)
