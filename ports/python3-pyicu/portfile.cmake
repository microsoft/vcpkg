vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/ovalhub/pyicu/archive/b2ec21a254a8ed88eed8417f96ec28454ebbf954.zip"
    FILENAME "pyicu.zip"
    SHA512 3acff7f3496de08f296bdfd7d53102bf322c87fabe76727a5631d61854a348b5fb06bd1bb5837ed50c59fe98196f681cec8c6ee208e2e44d496674cade97cfb4
)

vcpkg_extract_source_archive_ex(OUT_SOURCE_PATH SOURCE_PATH ARCHIVE ${ARCHIVE})
vcpkg_build_python(SOURCE_PATH ${SOURCE_PATH})
