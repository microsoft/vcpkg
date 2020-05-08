vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/sphinx-doc/sphinx/archive/62711bc081744cecba2af799ad8dbf678f6a97a4.zip"
    FILENAME "sphinx-doc.zip"
    SHA512 27c1e8a3a083a63a41a5079565906d78d8ec8e2ef29d6f0b45173b17fe76ce49466c196c36c4ec966fcd92f51923e695ef74d20aed9aa20d10ce9cdc1ff25dc1
)

vcpkg_extract_source_archive_ex(OUT_SOURCE_PATH SOURCE_PATH ARCHIVE ${ARCHIVE})
vcpkg_build_python(SOURCE_PATH ${SOURCE_PATH})
