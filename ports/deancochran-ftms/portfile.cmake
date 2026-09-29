vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/deancochran/ftms/releases/download/c-v${VERSION}/ftms-c-${VERSION}.tar.gz"
    FILENAME "ftms-c-${VERSION}.tar.gz"
    SHA512 8be9e00e60f594322f619816c56001da8527be524a3c8990149383bf827387f3885c1dc4411a1d38e0c8a8041cf6bd6995f8372f52fc7fa9bb7575f855c776ff
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ftms CONFIG_PATH lib/cmake/ftms)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/licenses"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
