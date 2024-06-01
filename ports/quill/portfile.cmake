vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO odygrd/quill
    REF v${VERSION}
    SHA512 5bd77416f1cc2218a72d49a51eefd04a08ccd535b798d6754eb5e80931c750d9d07a80b231b5c5f839235867392320792e78fde5d4b8cdb751f3dabc1d41c6e8
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/quill/include/ DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
