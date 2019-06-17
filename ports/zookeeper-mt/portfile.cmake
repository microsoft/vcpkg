include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "http://archive.apache.org/dist/zookeeper/zookeeper-3.5.4-beta/zookeeper-3.5.4-beta.tar.gz"
    FILENAME "zookeeper-3.5.4-beta.tar.gz"
    SHA512 3b45ea03f1f710310633141e5190cd9c7d734d0075bde996c82fe1e4e40a86a2aa48c41412ac7d7fd71c68b2f4c2497482d321b495b7283a57c9a2f0fba9a62e
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE} 
    PATCHES "cmake_build.patch"
)

set(SOURCE_PATH ${SOURCE_PATH}/src/c)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/zookeeper-mt RENAME copyright)

vcpkg_copy_pdbs()
