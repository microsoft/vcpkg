vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO think-cell/range
    REF 498839d41519d38bb81089f7d0f517026bd042cc
    SHA512 1292ba4dd994aab2cb620c24ebd03437a47e426368ed803579dad13a3fa52762cefe42c77c9921d5c4bcbd6592775714191de63097c230e50f9b59b9498005e5
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/range DESTINATION ${CURRENT_PACKAGES_DIR}/include/think-cell FILES_MATCHING PATTERN "*.h")

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/think-cell-range)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/think-cell-range/COPYING ${CURRENT_PACKAGES_DIR}/share/think-cell-range/copyright)
file(COPY ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/think-cell-range)

file(COPY ${SOURCE_PATH}/range/range.example.cpp DESTINATION ${CURRENT_PACKAGES_DIR}/share/think-cell-range)
