vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick_queue
    REF "v${VERSION}"
    SHA512 2756986b1dbb646cad8c6a71551be977d025087b42385a196e7a3c7f1ef8b6010fb91c2fca56eac51b4526c29abf12ef83cba1aeb53453c2c86522ecaabbfda9
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SLICK_QUEUE_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME slick_queue
    CONFIG_PATH lib/cmake/slick_queue
)

# Header-only library - remove lib directory
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
