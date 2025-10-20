vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/hanjingo/high-jump/releases/download/v1.0.3/high-jump-source-v1.0.3.tar.gz"
    FILENAME "high-jump-source-v1.0.3.tar.gz"
    SHA512 584886e5d8e574f6eaaed00bf9d8a3d4fef9fb6c55b8e94d7d04b8418da66156756471dbe64eeadde5e856964b91f53d78418fce3c6852d9799a7acca1745519
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_LIB=OFF
        -DBUILD_EXAMPLE=OFF
        -DBUILD_TEST=OFF
        -DBUILD_BENCH=OFF
)

vcpkg_cmake_install()

# Remove debug include files if they exist
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/include")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
endif()

# Remove empty debug directory if it exists
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug" AND IS_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
endif()

# Install usage file so vcpkg post-build checks pass
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
