vcpkg_download_distfile(ARCHIVE
    URLS "https://files.pythonhosted.org/packages/a5/bb/7e707d8001aca96f15f684b02176ecb0575786f041293f090b44ea04f2d0/flake8-3.7.9.tar.gz"
    FILENAME "flake8-3.7.9.tar.gz"
    SHA512 c3c753ad050d8a8f87f7c28c8a1c953ed9bd04f08b09512d9323152b4eebb57d67fbfb0f5317d629174fa12fa234e1a86d6a633dd951fff6a45330b1c4f62850
)

vcpkg_extract_source_archive_ex(OUT_SOURCE_PATH SOURCE_PATH ARCHIVE ${ARCHIVE})
vcpkg_build_python(SOURCE_PATH ${SOURCE_PATH})
