vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.onelab.info
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gl2ps/gl2ps
    REF gl2ps_1_4_2
    SHA512 cb4abd79f6790e229a0b05a6d12e4bd4d24885c89c4cb8644e49b0459361565c5c5379b53d85f59eeaba16144d3288dbd06c90f55a739f0928a788224ccb8085
    HEAD_REF master
    PATCHES
        separate-static-dynamic-build.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_GLUT=ON
    OPTIONS_DEBUG
        -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_cmake_install()

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/README.txt"
        "${SOURCE_PATH}/COPYING.LGPL"
        "${SOURCE_PATH}/COPYING.GL2PS"
)
