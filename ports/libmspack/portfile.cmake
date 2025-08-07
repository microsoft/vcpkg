set(LIB_NAME libmspack)
set(LIB_VERSION 0.11alpha)
set(LIB_FILENAME ${LIB_NAME}-${LIB_VERSION}.tar.gz)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.cabextract.org.uk/libmspack/${LIB_FILENAME}"
    FILENAME "${LIB_FILENAME}"
    SHA512 40c487e5b4e2f63a6cada26d29db51f605e8c29525a1cb088566d02cf2b1cc9dba263f80e2101d7f8e9d69cf7684a15bcaf791fb4891ad013a56afc7256dfa62
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/config.h" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/libmspack.def" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# License and man
file(INSTALL "${SOURCE_PATH}/COPYING.LIB" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_copy_pdbs()
