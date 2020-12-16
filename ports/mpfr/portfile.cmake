vcpkg_download_distfile(ARCHIVE
    URLS "http://www.mpfr.org/mpfr-4.0.2/mpfr-4.0.2.tar.xz" "https://ftp.gnu.org/gnu/mpfr/mpfr-4.0.2.tar.xz"
    FILENAME "mpfr-4.0.2.tar.xz"
    SHA512 d583555d08863bf36c89b289ae26bae353d9a31f08ee3894520992d2c26e5683c4c9c193d7ad139632f71c0a476d85ea76182702a98bf08dde7b6f65a54f8b88
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
