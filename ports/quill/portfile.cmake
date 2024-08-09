vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO odygrd/quill
    REF v${VERSION}
    SHA512 7192f58ce6dcbed87f950dfe53735c31444a1a657af8d087f76145c51649f8ecbc5be06c2b86d5e8ab708459db0cceb028dfda670cc841e8fc4167742d4ca297
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/quill/include/ DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
