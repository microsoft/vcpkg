set(CGL_RELEASE_TAG "b5000369741008aa3017021c1fc171e61ea54a09")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO endingly/games101-cgl
    REF ${CGL_RELEASE_TAG}
    SHA512  d553109d651f3e005be7951a3c01368c1d0cec808615a80c250c3a2c597c60419e3ce31ac6ac093da07c5c7f45fabc1bc09c1a01f4fab88469d9d47096ff7e25
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license")

