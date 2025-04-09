vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/oboe
    REF ${VERSION}
    SHA512 7eeaf85f9889e03dd1e7f5de0e9f2cee815fc555fddfdb8c4d3450d67f6ae11b0ca43b63c73e869bfc4629d2f8e5bdb23a5833c665ca5226c339f74b9b34a8ad
    HEAD_REF master
    PATCHES
        fix_install.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
