vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO odygrd/quill
    REF v${VERSION}
    SHA512 1be86328d59ecb8d4a91c3c8ece4c047837bdf95f2eaa06c7bc0dfc11f6a7299579b2467c9f198f679a1474006f73a78d0f564f887682cf958698b9ba443a2e4
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/quill/include/ DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
