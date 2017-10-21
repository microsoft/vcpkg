
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/uriparser-0.8.4)
vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/uriparser/files/Sources/0.8.4/uriparser-0.8.4.zip/download"
    FILENAME "uriparser-0.8.4.zip"
    SHA512 c22a98a027c4caa1d3559b1d3112f7ac567a489037d2b38f1999483f623a2e8d79fbacdc8859fe4e669a12f0f55935179f7be2f4424c61e51d1d68f6ced37185
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/uriparser RENAME copyright)
