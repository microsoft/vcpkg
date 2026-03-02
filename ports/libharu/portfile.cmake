vcpkg_download_distfile(
    PR351
    URLS "https://github.com/libharu/libharu/commit/4c87178a92097d59ecb9a3271341df4944b52225.patch?full_index=1"
    FILENAME "pr351.patch"
    SHA512 43049c3db9ab52f4550dd71218f0115c5f039caaf82e19671e295bb0e12ae6f9750cd18a944bf88819f7fc67cfecdbc8425eff1e387b2a6935847b5810d8c048
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libharu/libharu
    REF "v${VERSION}"
    SHA512 677523f927ecc925d95c91ebb1cb3d1146c2ffc86031c6fc05fc038893fd38babde2abf16683e0b76d1e2b8554c64bf2278649a0f70b08a0f187c2135fc14220
    HEAD_REF master
    PATCHES
        export-targets.patch
        "${PR351}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-libharu)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/libharu/bindings"
    "${CURRENT_PACKAGES_DIR}/share/libharu/README.md"
    "${CURRENT_PACKAGES_DIR}/share/libharu/CHANGES"
    "${CURRENT_PACKAGES_DIR}/share/libharu/INSTALL"
)

vcpkg_copy_pdbs()
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
