vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO odygrd/quill
    REF v${VERSION}
    SHA512 d8bda35da910c364566cd41cd8011542d62ddbb5d81d89668ccec6bb02b8bc5761b47f52a0111e0175a4ced50a34270fc913ac904d13311ffacf3c00cc471007
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/quill/include/ DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
