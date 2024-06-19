vcpkg_download_distfile(ARCHIVE
	URLS "https://pagure.io/libaio/archive/libaio-${VERSION}/libaio-libaio-${VERSION}.tar.gz"
    FILENAME "libaio-${VERSION}.tar.gz"
    SHA512 8058c927de0b5f7079fc232d2be23272537694bf271488af1dc0330b58afc307931792ab138512c5e00aa3ea921935a6d862f575fb0cc2bf323de63d8df208cd
)
vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        cmake.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
