include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/range-61e184a102d7818fd18f293c9ef99e6ebb59c222)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/think-cell/range/archive/61e184a102d7818fd18f293c9ef99e6ebb59c222.zip"
    FILENAME "think-cell_range-61e184a.zip"
    SHA512 1d27039918954624f98638636d107b4f8a997bee264552437f6229da4bce7fda31e67ac6f7b3b92a6dfa8d466b4ca6c05c1e516f3e7b37e0853d7d4153ef9587
)
vcpkg_extract_source_archive(${ARCHIVE})

file(INSTALL ${SOURCE_PATH}/range DESTINATION ${CURRENT_PACKAGES_DIR}/include/think-cell FILES_MATCHING PATTERN "*.h")

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/think-cell-range)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/think-cell-range/COPYING ${CURRENT_PACKAGES_DIR}/share/think-cell-range/copyright)

file(COPY ${SOURCE_PATH}/range/range.example.cpp DESTINATION ${CURRENT_PACKAGES_DIR}/share/think-cell-range)

vcpkg_apply_patches(
    SOURCE_PATH ${CURRENT_INSTALLED_DIR}/include
    PATCHES "${SOURCE_PATH}/boost_patches/has_range_iterator.patch"
)
