vcpkg_download_distfile(ARCHIVE
    URLS "https://files.pythonhosted.org/packages/42/64/fc7c506d14d8b6ed363e7798ffec2dfe4ba21e14dda4cfab99f4430cba3a/Mako-1.1.2.tar.gz"
    FILENAME "Mako-1.1.2.tar.gz"
    SHA512 73b7a32ceb6e39dc2491734546c83a752bf0c8bc7546bb236801c02a5bccc5b59f2440333a328ff747eee936612dd12279f08d27d76f065fd589081d232692a8
)

vcpkg_extract_source_archive_ex(OUT_SOURCE_PATH SOURCE_PATH ARCHIVE ${ARCHIVE})
vcpkg_build_python(SOURCE_PATH ${SOURCE_PATH})
