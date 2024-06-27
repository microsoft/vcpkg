vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO odygrd/quill
    REF v${VERSION}
    SHA512 bf1708107342f8a300f60889ec266e26c2dc5037e85aa488b28fc02ada7c02ecd0f0f9b73d95cf6336a11f6e8bd2cdc149d2b3648d0971b4e17c8c9c870cc919
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/quill/include/ DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
