include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(BASE_PATH ${CURRENT_BUILDTREES_DIR}/src/libdisasm-0.23)
set(SOURCE_PATH ${BASE_PATH}/libdisasm)

vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/bastard/files/libdisasm/0.23/libdisasm-0.23.tar.gz"
    FILENAME "libdisasm-0.23.tar.gz"
    SHA512 29eecfbfd8168188242278a1a38f0c90770d0581a52d4600ae6343829dd0d6607b98329f12a3d7409d43dd56dca6a7d1eb25d58a001c2bfd3eb8474c0e7879e7
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/sizeofvoid.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})


vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${BASE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libdisasm RENAME copyright)
