vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/conda/conda/archive/4.8.3.tar.gz"
    FILENAME "4.8.3.tar.gz"
    SHA512 e49036a93d14fc282443aef69b8d2f571da7d30e8255cd08081d7ed6e9c4c68e007707ac5d38105768b89c5fbdee47e4baa36037a80a27d2159513257d87c586
)

vcpkg_extract_source_archive_ex(OUT_SOURCE_PATH SOURCE_PATH ARCHIVE ${ARCHIVE})
vcpkg_build_python(SOURCE_PATH ${SOURCE_PATH})
