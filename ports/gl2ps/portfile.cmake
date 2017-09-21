include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/gl2ps-gl2ps_1_4_0-e7b16f8f80382e45b681651e6381de09250243a6)
vcpkg_download_distfile(ARCHIVE
    URLS "http://gitlab.onelab.info/gl2ps/gl2ps/repository/archive.tar.gz?ref=gl2ps_1_4_0"
    FILENAME "gl2ps_1_4_0.tar.gz"
    SHA512 6ec18debdf94e8de22ca7084fe6fef72fb858fc6295a35fa3c98c3c45211f9f72e23a14224a85877f64031077da4978b8d5d81f24dfe18de8c2ec32a680eba60
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/separate-static-dynamic-build.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING.GL2PS DESTINATION ${CURRENT_PACKAGES_DIR}/share/gl2ps RENAME copyright)
file(INSTALL ${SOURCE_PATH}/COPYING.LGPL DESTINATION ${CURRENT_PACKAGES_DIR}/share/gl2ps RENAME copyright.LGPL)
