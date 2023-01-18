vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "http://plib.sourceforge.net/dist/plib-1.8.5.tar.gz"
    FILENAME "plib-1.8.5.tar.gz"
    SHA512 17154cc77243fe576c2bcbcb0285b98aef1a0634658f5473e95fe0ac8fa3ed477dbe5620e44ccf0b7cc616f812af0cd44d6fcbba0c563180d3b61c9d6f158e1d
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
