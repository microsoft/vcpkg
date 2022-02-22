vcpkg_download_distfile(ARCHIVE
    URLS http://baical.net/files/libP7Client_v5.6.zip
    FILENAME libP7Client_v5.6.zip
    SHA512 992256854b717a45ae9e11ed16aa27b8b054de97718f027664634597d756aa26fe10dcad765cde7695802c90def46461abbcbfde81923fdd40ea2b659e1a8240
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    NO_REMOVE_ONE_LEVEL
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
