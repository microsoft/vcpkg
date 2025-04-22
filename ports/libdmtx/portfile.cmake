vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dmtx/libdmtx
    REF v${VERSION}
    SHA512 802a697669afeb74da0cc3736fe7301fcc1653c1e3bebc343a8baf76e52226cc5509231519343267a92e22ebdfcc5b2825380339991340f054f0a6685d2ffcdc
    PATCHES
        001-cmake-add-install-target.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
