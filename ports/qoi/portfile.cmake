#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO phoboslab/qoi
    REF 19b3b4087b66963a3699ee45f05ec9ef205d7c0e # committed on 2023-08-10
    SHA512 8131031ba4b3b3c50838eb83db44bed0bf2e3fc820f18a9e48202801aebef4179f9b465354487070d7bc1feea79461abe581eecde00d61a21e27fe2b8a52699f
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/qoi.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
