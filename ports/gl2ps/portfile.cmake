vcpkg_from_gitlab(
    GITLAB_URL http://gitlab.onelab.info
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gl2ps/gl2ps
    REF gl2ps_1_4_2
    SHA512 cb4abd79f6790e229a0b05a6d12e4bd4d24885c89c4cb8644e49b0459361565c5c5379b53d85f59eeaba16144d3288dbd06c90f55a739f0928a788224ccb8085
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
file(INSTALL ${SOURCE_PATH}/COPYING.GL2PS DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/COPYING.LGPL DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright.LGPL)
