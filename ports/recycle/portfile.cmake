vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO steinwurf/recycle
    REF "${VERSION}"
    SHA512 cc11dffe5a5aa6cf1f1c1b0c53830332edf784d7bac21608c8d04f8e077381df2e4a65c8664319f23bb80fc01240a79d314bd60c70b90b988e0319b2704da60d
    PATCHES
        disable-tests.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.rst")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
