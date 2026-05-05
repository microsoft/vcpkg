vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO max0x7ba/atomic_queue
    REF "v${VERSION}"
    SHA512 6046c451b2bb032187cfe8fb959c8ab27d6876df01028b52484c89dcd77d2553d68cd24d91611e21b91fdf0ca6e4f772edcd20dae7d88adb27374f91634ff7dd
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
