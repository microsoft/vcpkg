vcpkg_download_distfile(ARCHIVE
    URLS http://baical.net/files/libP7Client_v5.6.zip
    FILENAME libP7Client_v5.6.zip
    SHA512 992256854b717a45ae9e11ed16aa27b8b054de97718f027664634597d756aa26fe10dcad765cde7695802c90def46461abbcbfde81923fdd40ea2b659e1a8240
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    NO_REMOVE_ONE_LEVEL
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.txt")
