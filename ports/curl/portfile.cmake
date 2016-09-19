include(vcpkg_common_functions)
vcpkg_download_distfile(ARCHIVE_FILE
    URL "https://curl.haxx.se/download/curl-7.48.0.tar.bz2"
    FILENAME "curl-7.48.0.tar.bz2"
    MD5 d42e0fc34a5cace5739631cc040974fe
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

vcpkg_configure_cmake(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/curl-7.48.0
    OPTIONS
        -DBUILD_CURL_TESTS=OFF
        -DBUILD_CURL_EXE=OFF
        -DENABLE_MANUAL=OFF
    OPTIONS_DEBUG
        -DENABLE_DEBUG=ON
)

vcpkg_build_cmake()
vcpkg_install_cmake()

file(INSTALL ${CURRENT_BUILDTREES_DIR}/src/curl-7.48.0/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/curl RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
vcpkg_copy_pdbs()