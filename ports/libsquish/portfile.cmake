include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "https://downloads.sourceforge.net/project/libsquish/libsquish-1.15.tgz"
    FILENAME "libsquish-1.15.tgz"
    SHA512 5b569b7023874c7a43063107e2e428ea19e6eb00de045a4a13fafe852ed5402093db4b65d540b5971ec2be0d21cb97dfad9161ebfe6cf6e5376174ff6c6c3e7a
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE} 
    NO_REMOVE_ONE_LEVEL
    REF v1.15
    PATCHES
        fix-export-symbols.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
