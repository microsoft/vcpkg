vcpkg_download_distfile(ARCHIVE_FILE
    URLS "http://www.netlib.org/voronoi/triangle.zip"
    FILENAME "triangle.zip"
    SHA512 c9c1ac527c4bf836ed877b1c5495abf9fd2c453741f4c9698777e23cde939ebf0dd73c84cec64f35a93ca01bff4b86ce32ec559da33e570a0744a764e46d2186
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    NO_REMOVE_ONE_LEVEL
    ARCHIVE "${ARCHIVE_FILE}"
    PATCHES
        "enable_64bit_architecture.patch"
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/exports.def" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/tools")

file(INSTALL "${SOURCE_PATH}/README" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
