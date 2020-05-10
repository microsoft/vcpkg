vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/pydata/numexpr/archive/d274455bc6a092cb49c0606f61a67c61afb86f72.zip"
    FILENAME "numexpr.zip"
    SHA512 79def09bf2c64569be479e84a0556b4fa2cd6afedc1ba6f0963fe48aa3e6c208c6aadb2d03c1e816f0123ac13a9ee1e55256880330d00fed7003faaa9ac9dcf6
)

vcpkg_extract_source_archive_ex(OUT_SOURCE_PATH SOURCE_PATH ARCHIVE ${ARCHIVE})
vcpkg_build_python(SOURCE_PATH ${SOURCE_PATH})
