vcpkg_download_distfile(
    ARCHIVE
    URLS "https://exiftool.org/cpp_exiftool/cpp_exiftool.tar.gz"
    FILENAME "cpp_exiftool-${VERSION}.tar.gz"
    SHA512 d362e622deeb2a04aa6d694e0c8ffabf610af30cb30c29430811e77b0faa86177fe3409ec228ead9af998a99eb6d3ffa601652c6128a96f20eb60a03e0f64292
)
vcpkg_extract_source_archive(SOURCE_PATH ARCHIVE "${ARCHIVE}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_copy_pdbs()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-cpp-exiftool)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/README")
