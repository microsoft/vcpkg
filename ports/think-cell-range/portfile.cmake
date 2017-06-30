include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/range-498839d41519d38bb81089f7d0f517026bd042cc)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/think-cell/range/archive/498839d41519d38bb81089f7d0f517026bd042cc.zip"
    FILENAME "think-cell_range-498839d.zip"
    SHA512 801e987c828c954cb50f9a6f9f2feee2ce05f7232d531ecce7394800ecc5a750992795da173fb72b6efcabd6978015a650730682b7db3f874fb8aaac28869711
)
vcpkg_extract_source_archive(${ARCHIVE})

file(INSTALL ${SOURCE_PATH}/range DESTINATION ${CURRENT_PACKAGES_DIR}/include/think-cell FILES_MATCHING PATTERN "*.h")

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/think-cell-range)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/think-cell-range/COPYING ${CURRENT_PACKAGES_DIR}/share/think-cell-range/copyright)
file(COPY ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/think-cell-range)

file(COPY ${SOURCE_PATH}/range/range.example.cpp DESTINATION ${CURRENT_PACKAGES_DIR}/share/think-cell-range)
