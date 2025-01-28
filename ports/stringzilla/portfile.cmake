# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/StringZilla
    REF "v${VERSION}"
    SHA512 bb5dd5301a952e2ca9d64089f1380a9828942159a41c2997f70724768144b6f7a4fb4d5a304f5c3d4b2cf8584c279d6641a6854924cc12d06a844cdbe42c7ab8
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
