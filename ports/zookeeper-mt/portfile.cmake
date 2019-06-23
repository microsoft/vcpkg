include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "https://archive.apache.org/dist/zookeeper/zookeeper-3.5.5/apache-zookeeper-3.5.5.tar.gz"
    FILENAME "zookeeper-3.5.5.tar.gz"
    SHA512 4e22df899a83ca3cc15f6d94daadb1a8631fb4108e67b4f56d1f4fcf95f10f89c8ff1fb8a7c84799a3856d8803a8db1e1f2f3fe1b7dc0d6cedf485ef90fd212d
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
