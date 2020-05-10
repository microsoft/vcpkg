vcpkg_download_distfile(ARCHIVE
    URLS "https://files.pythonhosted.org/packages/8c/9b/26d0d2ab67e16500c8e68db07e66335f4a51fa1236a794e21ba670ac0dc4/flake8-comprehensions-3.2.2.tar.gz"
    FILENAME "flake8-comprehensions-3.2.2.tar.gz"
    SHA512 15a968494c32bff87879bfc922cbd9075bc2a55e2de999dd5d5dbfd5c1e6e902d7114a9c16277b3d2e192651c25b0a3aa525e6abb54c6825614e7da1175dd2fe
)

vcpkg_extract_source_archive_ex(OUT_SOURCE_PATH SOURCE_PATH ARCHIVE ${ARCHIVE})
vcpkg_build_python(SOURCE_PATH ${SOURCE_PATH})
