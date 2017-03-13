include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/range-e2d3018c3a797e7328dea005e72b34cace8b1fc6)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/think-cell/range/archive/e2d3018c3a797e7328dea005e72b34cace8b1fc6.zip"
    FILENAME "think-cell_range-e2d3018.zip"
    SHA512 13c74aba4950a84fdf446c976564030b18a740c5ce42b7650116a0559ba9e9a59471ff0f80132c626bc442402b3717805d3615b9ea70751e2dd1e648fd9f7916
)
vcpkg_extract_source_archive(${ARCHIVE})

file(INSTALL ${SOURCE_PATH}/range DESTINATION ${CURRENT_PACKAGES_DIR}/include/think-cell FILES_MATCHING PATTERN "*.h")

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/think-cell-range)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/think-cell-range/COPYING ${CURRENT_PACKAGES_DIR}/share/think-cell-range/copyright)
file(COPY ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/think-cell-range)

file(COPY ${SOURCE_PATH}/range/range.example.cpp DESTINATION ${CURRENT_PACKAGES_DIR}/share/think-cell-range)
