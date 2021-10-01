set(LIB_NAME libmspack)
set(LIB_VERSION 0.10.1alpha)
set(LIB_FILENAME ${LIB_NAME}-${LIB_VERSION}.tar.gz)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.cabextract.org.uk/libmspack/${LIB_FILENAME}"
    FILENAME "${LIB_FILENAME}"
    SHA512 a7b5f7caa49190c5021f3e768b92f2e51cc0ce685c9ab6ed6fb36de885c73231b58d47a8a3b5c5aa5c9ac56c25c500eb683d84dbf11f09f97f6cb4fff5adc245
)

vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/config.h DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/libmspack.def DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# License and man
file(INSTALL ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/${LIB_NAME} RENAME copyright)

vcpkg_copy_pdbs()
