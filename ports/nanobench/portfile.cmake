vcpkg_minimum_required(VERSION 2022-11-10)

# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinus/nanobench
    REF v${VERSION}
    SHA512 2d0c9e912fd2e777e3c75ac52d51daff720b51a776e5fc9f9d1e198f8b106bc13bd21219f195bf9c6c80b5a13fdb6b805c436d3060ec46fbd1f2ef67d58945db
    HEAD_REF master
    PATCHES
        fix-cmakefile.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
