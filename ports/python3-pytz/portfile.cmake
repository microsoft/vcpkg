vcpkg_download_distfile(ARCHIVE
    URLS "https://files.pythonhosted.org/packages/f4/f6/94fee50f4d54f58637d4b9987a1b862aeb6cd969e73623e02c5c00755577/pytz-2020.1.tar.gz"
    FILENAME "pytz-2020.1.tar.gz"
    SHA512 4f652ab400bac0bd83ed305be7540094e674029a0cbde7da280adfd911b8c0a44023799b7c61971a5a61a1d6e3992c5b621e5e95bbfe962f310d5f26d4fda3ce
)

vcpkg_extract_source_archive_ex(OUT_SOURCE_PATH SOURCE_PATH ARCHIVE ${ARCHIVE})
vcpkg_build_python(SOURCE_PATH ${SOURCE_PATH})
