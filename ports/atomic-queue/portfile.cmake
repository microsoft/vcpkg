vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO max0x7ba/atomic_queue
    REF "v${VERSION}"
    SHA512 9db0ebfb46d2968a7126045aa6584f1145892f2d8cadc74a047d1c1423fe85291e548629b7fd507b4e38584e7f95e1773260b7e44332aeea8c085d2d86d9b65a
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DATOMIC_QUEUE_ENABLE_INSTALL=ON
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME atomic_queue)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
