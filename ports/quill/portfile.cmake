vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO odygrd/quill
    REF v${VERSION}
    SHA512 ab9efd4da3078e532bcff381149dcfc048c08af37f889ceb49eaad311c4235cd42fd7c503aa375134b5a301fd8b8cf96ca698ce3273c28e626e0c85577ca1ca7
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/quill/include/ DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
