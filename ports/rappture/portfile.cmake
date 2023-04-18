vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://nanohub.org/app/site/downloads/rappture/rappture-src-20130903.tar.gz"
    FILENAME "rappture-src-20130903.tar.gz"
    SHA512 3b42569d056c5e80762eada3aff23d230d4ba8f6f0078de44d8571a713dde91e31e66fe3c37ceb66e934a1410b338fb481aeb5a29ef56b53da4ad2e8a2a2ae59
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        rappture.patch
        include_functional.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license.terms")
