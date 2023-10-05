vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/cppp-project/cppp-reiconv/releases/download/v2.1.0/cppp-reiconv-v2.1.0.zip"
    FILENAME "cppp-reiconv-v2.1.0.zip"
    SHA512 32a17e9931cbd329c15f34efe95a435857eb0b5ceeda862d0cf81a29141aa91da3329de5e21d0d718e37dadece3c5bfdc42efe7d3be46a593760540cb7240585
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR ${PYTHON3} DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
     OPTIONS -DENABLE_TEST=OFF -DENABLE_EXTRA=ON
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
