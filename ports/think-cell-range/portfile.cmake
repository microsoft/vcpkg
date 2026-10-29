vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO think-cell/think-cell-library
    REF "${VERSION}"
    SHA512 dbb391982fc8050a020c9597fa8608abf87f351b84b7060cfadac4670fd4564f34836a8862f42647983f601a21d6d8bbda95429fc6e2788e94a343fbba09ae99
    HEAD_REF main
)

file(INSTALL "${SOURCE_PATH}/tc/range" DESTINATION "${CURRENT_PACKAGES_DIR}/include/think-cell" FILES_MATCHING PATTERN "*.h")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE_1_0.txt")
file(COPY "${SOURCE_PATH}/README.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(COPY "${SOURCE_PATH}/range.example.cpp" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
