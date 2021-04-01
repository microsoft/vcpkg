vcpkg_download_distfile(ARCHIVE
    URLS "https://code.soundsoftware.ac.uk/attachments/download/2589/vamp-plugin-sdk-2.9.0.zip"
    FILENAME "vamp-plugin-sdk-2.9.0.zip"
    SHA512 38222f074c17ba420fcc1ad6639048c8f282b892a4baf4257481d7f65f2b5a62685d8bc8e9cbbb5b77063a92f33dc3d2f138ea9b21c475ae1c456146056720ed
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# # Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
