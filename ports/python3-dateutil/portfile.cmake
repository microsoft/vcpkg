vcpkg_download_distfile(ARCHIVE
    URLS "https://labix.org/download/python-dateutil/python-dateutil-2.0.tar.gz"
    FILENAME "python-dateutil-2.0.tar.gz"
    SHA512 49571d2244fbfb8c3f5e9746f20ec7272ff7fb5d2d738403382d5aee063b88b64440084ab5c311973072e2d7f6cf5c6557990eed9ba20cf0c4321cf72c8a05a5
)

vcpkg_extract_source_archive_ex(OUT_SOURCE_PATH SOURCE_PATH ARCHIVE ${ARCHIVE})
vcpkg_build_python(SOURCE_PATH ${SOURCE_PATH})
