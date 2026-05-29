# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/StringZilla
    REF "v${VERSION}"
    SHA512 ff1f20f89a0ee7ad63175c0ce4dde06eebf03fe836b40df31ffd345c73e22472278774555ea4bcc25122be03b3cf001a0d3a43488444d216c2a1fee10900fdb8
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
