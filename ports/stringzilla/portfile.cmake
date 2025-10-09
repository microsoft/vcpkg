# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/StringZilla
    REF "v${VERSION}"
    SHA512 7143104a1706cd5fbd2ef939ac4c4cf2ab2964551d33b54e3d711c5e423d2d2dfdb2638dc1987b09c0a9795d03f5a028de835596a1e6ed5fd152567fdd53065e
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
