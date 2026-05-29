vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO erikerlandson/st_tree
    REF "version_${VERSION}"
    SHA512 dd555fce81cde5aa4b30854c856eb7dfd61ee1a7f5874c7538990fa331cfbe85838cb2a547af5e255debf04be3e0f5599701ce64743071f935a97162e48cd59d
    HEAD_REF develop
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DENABLE_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake" PACKAGE_NAME st_tree)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
