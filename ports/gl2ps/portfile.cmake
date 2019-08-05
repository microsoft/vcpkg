include(vcpkg_common_functions)

vcpkg_from_gitlab(
    GITLAB_URL http://gitlab.onelab.info
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gl2ps/gl2ps
    REF gl2ps_1_4_0
    SHA512 ee10e3fd312eae896934c39b8d115f28017874f918e4dd3350ca8f7cbf47dfc44101a5c6eb8826707620fcc336ca51ddc4eb7bf653af4b27651277625bac3cce
    HEAD_REF master
    PATCHES separate-static-dynamic-build.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING.GL2PS DESTINATION ${CURRENT_PACKAGES_DIR}/share/gl2ps RENAME copyright)
file(INSTALL ${SOURCE_PATH}/COPYING.LGPL DESTINATION ${CURRENT_PACKAGES_DIR}/share/gl2ps RENAME copyright.LGPL)
