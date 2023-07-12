vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DeveloperPaul123/thread-pool
    REF ${VERSION}
    SHA512 4ab6cbb2f23dbfe46d04d117173b9df3f07355752801fc83a371481a4ef3f3dfe52b48c3bc4f40d75a367e4f00d80ddb29c061adae2b6829a591e33a276984c6
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    GENERATOR "Ninja"
    OPTIONS
        -DTP_BUILD_TESTS=OFF
        -DTP_BUILD_EXAMPLES=OFF
        -DTP_BUILD_BENCHMARKS=OFF
        -DFETCHCONTENT_FULLY_DISCONNECTED=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME ThreadPool
    CONFIG_PATH lib/cmake/ThreadPool-${VERSION}
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/" "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
