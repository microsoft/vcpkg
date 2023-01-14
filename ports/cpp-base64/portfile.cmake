vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ReneNyffenegger/cpp-base64
    REF V2.rc.08 # V2.rc.08
    SHA512 8d115c3341bee31c3d83f5ad07d457a507f42d58bb5db8d9ead213494f7f25065eeeac06226f9cc34235c0360eb893e7bc66a95aa3bfbc9ea0d179f5a0b7af0a
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/base64.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})
file(COPY ${SOURCE_PATH}/base64.cpp DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
