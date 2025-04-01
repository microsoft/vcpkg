vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/dmtx/libdmtx/archive/refs/tags/v0.7.7.tar.gz"
    FILENAME "v0.7.7.tar.gz"
    SHA512 802a697669afeb74da0cc3736fe7301fcc1653c1e3bebc343a8baf76e52226cc5509231519343267a92e22ebdfcc5b2825380339991340f054f0a6685d2ffcdc
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        001-cmake-add-install-target.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ..
    OPTIONS_DEBUG
        -DBUILD_TESTING=ON
)

set(VCPKG_POLICY_ALLOW_DEBUG_INCLUDE enabled)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
