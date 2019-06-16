
include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/cgicc-3.2.19)
vcpkg_download_distfile(ARCHIVE
    URLS "http://ftp.gnu.org/gnu/cgicc/cgicc-3.2.19.tar.gz"
    FILENAME "cgicc-3.2.19.tar.gz"
    SHA512 c361923cf3ac876bc3fc94dffd040d2be7cd44751d8534f4cfa3545e9f58a8ec35ebcd902a8ce6a19da0efe52db67506d8b02e5cc868188d187ce3092519abdf
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON -DDISABLE_INSTALL_TOOLS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING.DOC DESTINATION ${CURRENT_PACKAGES_DIR}/share/cgicc RENAME copyright)
