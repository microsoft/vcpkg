set(7ZIP_VERSION "2301")
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.7-zip.org/a/7z${7ZIP_VERSION}-src.7z"
    FILENAME "7z${7ZIP_VERSION}-src.7z"
    SHA512 45038fc49b0be8e7435939a79ad9f46f360b43b651148a8cde74fafdb8536f51a4be3b1ea91e06203267e5121267f6601f8ae6678feaf18e4b7a4f79a16730e7
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    NO_REMOVE_ONE_LEVEL
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/7zip-config.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup()

file(
    INSTALL "${SOURCE_PATH}/DOC/License.txt"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
