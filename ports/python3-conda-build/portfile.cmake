vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/conda/conda-build/archive/3.19.3.tar.gz"
    FILENAME "3.19.3.tar.gz"
    SHA512 28e6825418c5c6eccdb7ce9b599a2f42202a640f2ae97876e8c7192223237a0c85ec8ca95f6ee500477bb7c8951f6808cdf35eb592f6f47119254f5c5f23c43a
)

vcpkg_extract_source_archive_ex(OUT_SOURCE_PATH SOURCE_PATH ARCHIVE ${ARCHIVE})
vcpkg_build_python(SOURCE_PATH ${SOURCE_PATH})
