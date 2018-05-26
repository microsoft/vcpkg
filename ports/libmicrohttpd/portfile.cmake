include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libmicrohttpd-0.9.55)
vcpkg_download_distfile(ARCHIVE
    URLS "ftp://ftp.gnu.org/gnu/libmicrohttpd/libmicrohttpd-0.9.55.tar.gz"
    FILENAME "libmicrohttpd-0.9.55.tar.gz"
    SHA512 b410e7253d7c98c40b5e8b8dcd1f93bcbb05c88717190e8dae73073d36465e8e5cfa53c6c5098de60051a5ec64dc423fd94f4b06537d8146b744aa99f5a0b173
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libmicrohttpd RENAME copyright)
