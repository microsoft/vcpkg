# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/StringZilla
    REF "v${VERSION}"
    SHA512 5c392e1cb49ea0eb7c4cf0e1378e0a419d1f403ff273ddf7d7fbf7224f9cebcccbd8cb173a0f43e1f20827cd5267cc56ec548196f1b1eb32aa9da1adf08faeb8
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
