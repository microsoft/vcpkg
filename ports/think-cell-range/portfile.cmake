include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/range-1d785d99b6d4e43b951bff51219e9304b012c3fe)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/think-cell/range/archive/1d785d99b6d4e43b951bff51219e9304b012c3fe.zip"
    FILENAME "think-cell_range-1d785d9.zip"
    SHA512 2248d9bcc053f67c4b30b640254bf89a2f4c753fb144219806358175fb897a264c330e870556568d3b2f6c6987f49a5a875492b36f614f19bca0e3b46d0c2490
)
vcpkg_extract_source_archive(${ARCHIVE})

file(INSTALL ${SOURCE_PATH}/range DESTINATION ${CURRENT_PACKAGES_DIR}/include/think-cell FILES_MATCHING PATTERN "*.h")

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/think-cell-range)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/think-cell-range/COPYING ${CURRENT_PACKAGES_DIR}/share/think-cell-range/copyright)
file(COPY ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/think-cell-range)

file(COPY ${SOURCE_PATH}/range/range.example.cpp DESTINATION ${CURRENT_PACKAGES_DIR}/share/think-cell-range)
