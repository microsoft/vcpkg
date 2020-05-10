vcpkg_download_distfile(ARCHIVE
    URLS "https://files.pythonhosted.org/packages/0a/af/a6d8aa7b8909a36074f517b15222e3a2fbd5ef3452c0a686e3d43043dd3b/Mako-1.0.12.tar.gz"
    FILENAME "Mako-1.0.12.tar.gz"
    SHA512 aa295880c07938425e661b8865fed7cf398ac257d6b84bdbef5a2c542bbae79cd27df363e81c10450c9b6c8e038360166480b06e701d5a5affeb7bd03a7f5d83
)

vcpkg_extract_source_archive_ex(OUT_SOURCE_PATH SOURCE_PATH ARCHIVE ${ARCHIVE})
vcpkg_build_python(SOURCE_PATH ${SOURCE_PATH})
