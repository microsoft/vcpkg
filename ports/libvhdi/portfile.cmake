set(LIB_FILENAME libvhdi-alpha-${VERSION}.tar.gz)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/libyal/libvhdi/releases/download/${VERSION}/${LIB_FILENAME}"
    FILENAME "${LIB_FILENAME}"
    SHA512 982ce91da22f174285aab00c26c4b26375f4d87afb08551a9c5a4d678e15010f066c624e1a0db87ae62a26d30d692a7f1c883dcbe748ebc3cf0e5817dbaa467f
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    SOURCE_BASE "${VERSION}"
    PATCHES macos_fixes.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libvhdi)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(
    FILE_LIST "${SOURCE_PATH}/COPYING"
)

vcpkg_copy_pdbs()
