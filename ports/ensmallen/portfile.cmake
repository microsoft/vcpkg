set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mlpack/ensmallen
    REF "${VERSION}"
    SHA512 9cc058dcb777b7a59c361afcd02d2ce787b08c86a26aefc1d67c42658d67d7b62e8d7b5138c02912c182bc9b0e1e039c4036478985e12e2e35746853a169e067
    HEAD_REF master
    PATCHES
        dependencies.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ensmallen)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYRIGHT.txt")
