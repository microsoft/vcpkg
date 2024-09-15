vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/SimSIMD
    REF "v${VERSION}"
    SHA512 8263aada695ce68a1eb671c46a294fd317f9bb5d3a3ec5b4a8ab27b8b8ea5801c639b6bac3ba889bd6153444c76b7fa6d2982c25003af4cdfd0d8bc007b783f8
    HEAD_REF main
)

file(INSTALL "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
