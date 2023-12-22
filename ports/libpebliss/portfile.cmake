vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/MMitsuha/libpebliss/archive/refs/heads/master.zip"
    FILENAME "libpebliss.zip"
    SHA512 7eb7d6b0e55aa8d9e9bcc7e55b04ee4ed428517b00406708f8952f69e128223bebf39819613d93dc9221b5083129a93cf6a35ee3a061c5db863ff7b4fd3a17c9
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
