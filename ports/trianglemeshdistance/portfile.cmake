vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO InteractiveComputerGraphics/TriangleMeshDistance
    REF v${VERSION}
    SHA512 5ef10d9b6376c1d399481e7cda645091823a463e92d4fb5c53a537ea3dec9dcd97459584d1c960081f80f00ff18c000733f4da79e1ea77dd66e63a17a1c08bbb
    PATCHES
        remove-tests.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
   
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
