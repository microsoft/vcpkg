#message(FATAL_ERROR "https://poppler.freedesktop.org/poppler-data-${VERSION}.tar.gz")
vcpkg_download_distfile(
    ARCHIVE
    URLS "https://poppler.freedesktop.org/poppler-data-${VERSION}.tar.gz"
    FILENAME "poppler-data-${VERSION}.tar.gz"
    SHA512 75f201e4c586ba47eb9a48a33ef6663fe353d0694b602feb7db282d73da7f0daffb0ff7e18e4a6cb40324305efa2413df562666939f4214e2dfd7ff00288f3de
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${VERSION}
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    )
vcpkg_cmake_install()
#file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/poppler-data" RENAME copyright)