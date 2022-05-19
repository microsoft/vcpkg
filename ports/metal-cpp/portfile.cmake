vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
vcpkg_download_distfile(
    archive
    URLS https://developer.apple.com/metal/cpp/files/metal-cpp_macOS12_iOS15.zip
    FILENAME metal-cpp-macos12-ios15.zip
    SHA512 dabb4109c7bf283288b5b3bd392892a7a52ad13b4d53a72a117a852f54b0a82871bec3e55c8493d8048365839bd1be37d72f872041f43db314622bb4a983921f
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${archive}"
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/impl.cpp" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

