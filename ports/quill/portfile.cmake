vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO odygrd/quill
    REF v${VERSION}
    SHA512 f41c0eea126cea4eda675e2380e59f1a6262a6bb3a32f7aeba53733f82ce4cbf3c169d3e7b0b5acd0fb9f95b8edc1854c64730271bbc24ec27fc05a66ebaf6d5
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/quill/include/ DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
