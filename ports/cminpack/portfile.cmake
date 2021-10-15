vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/devernay/cminpack/archive/refs/tags/v1.3.8.tar.gz"
    FILENAME "v1.3.8.tar.gz"
    SHA512 0cab275074a31af69dbaf3ef6d41b20184c7cf9f33c78014a69ae7a022246fa79e7b4851341c6934ca1e749955b7e1096a40b4300a109ad64ebb1b2ea5d1d8ae
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# # Handle copyright
file(INSTALL ${SOURCE_PATH}/CopyrightMINPACK.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/cminpack RENAME copyright)
