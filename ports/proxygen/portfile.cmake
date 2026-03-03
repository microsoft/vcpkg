vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/proxygen
    REF "v${VERSION}"
    SHA512 308c82858b0de19992bd29e32518d08a2502020b933d1796f7b65686dc5d4c2707189aa6d15dfad5a021abb9021a25aa11ade0a2f5ddafc1cea23cbb4744b81c
    HEAD_REF main
    PATCHES
        remove-register.patch
        folly-has-liburing.diff
        fix-dependency.patch
)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/gperf")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DPROXYGEN_PYTHON=${PYTHON3}"
        -DVCPKG_LOCK_FIND_PACKAGE_gflags=ON
        -DCMAKE_INSTALL_DIR=share/proxygen
        -DBUILD_SAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
