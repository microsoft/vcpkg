vcpkg_download_distfile(ARCHIVE
    URLS "https://files.pythonhosted.org/packages/5f/16/eab51d6571dfec2554248cb027c51babd04d97f594ab6359e0707361297d/cx_Freeze-5.1.1.tar.gz"
    FILENAME "cx_Freeze-5.1.1.tar.gz"
    SHA512 64f9c3b7f6c3003c1dc439fc2da7d0c13c5f146834e3ab8ece3921f1eb30c6e3eda480ccc84e61cc061597521b360cf8f5ef8e0bbcce1437157360c3d9c1adbc
)

vcpkg_extract_source_archive_ex(OUT_SOURCE_PATH SOURCE_PATH ARCHIVE ${ARCHIVE})

vcpkg_build_python(SOURCE_PATH ${SOURCE_PATH})
